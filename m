From: Patrick McHardy <kaber@trash.net>
Subject: Re: [2.6 patch] NF_CONNTRACK_H323 must depend on (IPV6 || IPV6=n)
Date: Tue, 30 Jan 2007 18:13:48 +0100
Message-ID: <45BF7CCC.9080306@trash.net>
References: <20070128222136.GZ6017@stusta.de>
	<20070128.155348.39160134.davem@davemloft.net>
	<20070129000011.GB6017@stusta.de>
	<20070128.160442.48527586.davem@davemloft.net>
	<20070129002108.GC6017@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, akpm@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter@lists.netfilter.org,
	David Miller <davem@davemloft.net>
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netfilter-bounces@lists.netfilter.org>
In-Reply-To: <20070129002108.GC6017@stusta.de>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter>,
	<mailto:netfilter-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter>
List-Post: <mailto:netfilter@lists.netfilter.org>
List-Help: <mailto:netfilter-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter>,
	<mailto:netfilter-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-bounces@lists.netfilter.org
Errors-To: netfilter-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Sun, Jan 28, 2007 at 04:04:42PM -0800, David Miller wrote:
> 
>>From: Adrian Bunk <bunk@stusta.de>
>>Date: Mon, 29 Jan 2007 01:00:11 +0100
>>
>>>"depends on IPV6" would fix the bug - but it would also make 
>>>NF_CONNTRACK_H323 unavailable for all people without IPV6 support in 
>>>their kernel.
>>
>>Yes, that is an issue.
>>
>>I guess with some slightly ugly ifdefs we could support the
>>whole matrix of possibilities.  But perhaps that's undesirable
>>for another reason.
>>...
> 
> 
> This depends on what NF_CONNTRACK_H323=y, IPV6=m is supposed to be:
> - not allowed (NF_CONNTRACK_H323 must be modular) or
> - NF_CONNTRACK_H323 can only be used for IPV4
> 
> My patch implements the first case.


Unfortunately a few ifdefs aren't enough to support IPV6=m,
NF_CONNTRACK_H323=y. For now I think Adrian's patch is the
best solution (IPV6=m isn't that useful anyway since it will
normally get loaded automatically when the first program
attempts to open an AF_INET6 socket and can't be unloaded),
but I'll look into moving the route lookup to the netfilter
AF ops in 2.6.21 so we can also support that configuration.


Acked-by: Patrick McHardy <kaber@trash.net>
