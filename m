From: "Stuart Macdonald" <stuart@ken-caryl.net>
Subject: RE: netfilter query
Date: Mon, 22 Nov 2004 18:47:17 -0700
Message-ID: <DHEOJAHAGKDLCDOHPMIECEFNCCAA.stuart@ken-caryl.net>
References: <Pine.LNX.4.61.0411221245470.20973@filer.marasystems.com>
Reply-To: <stuart@ken-caryl.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kernelnewbies@nl.linux.org, netfilter-devel@lists.netfilter.org,
  netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <kernelnewbies-bounce@nl.linux.org>
To: "Henrik Nordstrom" <hno@marasystems.com>,
  "cranium2003" <cranium2003@yahoo.com>
In-Reply-To: <Pine.LNX.4.61.0411221245470.20973@filer.marasystems.com>
Sender: kernelnewbies-bounce@nl.linux.org
Errors-to: kernelnewbies-bounce@nl.linux.org
List-help: <mailto:ecartis@nl.linux.org?Subject=help>
List-unsubscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=unsubscribe>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=subscribe>
List-owner: <mailto:ecartis-owner@nl.linux.org>
List-post: <mailto:kernelnewbies@nl.linux.org>
List-archive: <http://mail.nl.linux.org/kernelnewbies/>
List-Id: netdev.vger.kernel.org

Just a parallel thought here,

A different approach is to implement the Netfilter Bridge hooks and run a
box as a bridge. This requires a kernel parameter for Bridge to be enabled
when the kernel is built and then the brctl utility to setup the bridge. In
this manner, your bridge netfilter hooks always receive packets starting at
the MAC headers. You can parse from there to derive subsequent protocols:
IP, IPX, LLC, SNAP, NETBEUI...

Stuart



-----Original Message-----
From: kernelnewbies-bounce@nl.linux.org
[mailto:kernelnewbies-bounce@nl.linux.org]On Behalf Of Henrik Nordstrom
Sent: Monday, November 22, 2004 5:03 AM
To: cranium2003
Cc: kernelnewbies@nl.linux.org; netdev@oss.sgi.com;
netfilter-devel@lists.netfilter.org; linux-kernel@vger.kernel.org
Subject: Re: netfilter query


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

--
Kernelnewbies: Help each other learn about the Linux kernel.
Archive:       http://mail.nl.linux.org/kernelnewbies/
FAQ:           http://kernelnewbies.org/faq/



--
Kernelnewbies: Help each other learn about the Linux kernel.
Archive:       http://mail.nl.linux.org/kernelnewbies/
FAQ:           http://kernelnewbies.org/faq/
