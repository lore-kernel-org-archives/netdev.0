From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: netfilter query
Date: Mon, 22 Nov 2004 13:03:23 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0411221245470.20973@filer.marasystems.com>
References: <20041121153354.99557.qmail@web41404.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: kernelnewbies@nl.linux.org, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: cranium2003 <cranium2003@yahoo.com>
In-Reply-To: <20041121153354.99557.qmail@web41404.mail.yahoo.com>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Sun, 21 Nov 2004, cranium2003 wrote:

> Also,which headers are added when packet
> reaches to netfilter hook NF_IP_LOCAL_OUT? I found
> TCP/UDP/ICMP ,IP. Is that correct?

Yes.

netfilter is running at the IP layer and only reliably have access to IP 
headers and up. Lower level headers such as Ethernet MAC header is 
transport dependent and not always available, and certainly not available 
in NF_IP_LOCAL_OUT as it is not yet known the packet will be sent to an 
Ethernet.

In some netfilter hooks it is possible to rewind back to the Ethernet MAC 
header but one must be careful to verify that it really is an Ethernet 
packet one is looking at when doing this. Unfortunately there is no 
perfect solution how to detect this.. For an example of how one may try to 
look at the Ethernet MAC header see ipt_mac.c. But be warned that it is 
possible for non-Ethernet frames to pass the simple checks done there..

Regards
Henrik
