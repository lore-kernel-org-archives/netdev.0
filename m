From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 11:53:29 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.3.96.1030819114722.6826F-100000@gatekeeper.tmr.com>
References: <20030819145403.GA3407@alpha.home.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Richard Underwood <richard@aspectgroup.co.uk>,
   "'Alan Cox'" <alan@lxorguk.ukuu.org.uk>,
   "'David S. Miller'" <davem@redhat.com>,
   Stephan von Krawczynski <skraw@ithnet.com>, carlosev@newipnet.com,
   lamont@scriptkiddie.org, bloemsaa@xs4all.nl,
   Marcelo Tosatti <marcelo@conectiva.com.br>, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Willy Tarreau <willy@w.ods.org>
In-Reply-To: <20030819145403.GA3407@alpha.home.local>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003, Willy Tarreau wrote:

> Hello,
> 
> On Tue, Aug 19, 2003 at 03:34:43PM +0100, Richard Underwood wrote:

> > 	Now, since 172.24.0.80 is a Linux box, it's happily adding
> > 172.20.240.2 into its ARP table and reply to it, hence the reply.
> > 
> > 	But if I was to do this in the other direction (arp -d 172.20.240.1;
> > ping -I 172.24.0.1 172.20.240.1) then I'd lose connectivity over my default
> > route because 172.20.240.1 won't accept ARP packets from IP numbers not on
> > the connected subnet. The <incomplete> ARP entry will block any further ARP
> > requests from valid IP numbers.
> 
> This is exactly the case I calmly discussed privately with David then Alexey.
> Both explained me that in fact, the remote host shouldn't be filtering the ARP
> requests based on the source IP they provide, but agreed that it seems to be a
> general trend today. Alexey proposed a slight change which can at least solve
> this very common case by preventing the system from using the local address as
> a source IP if it is not on the interface through which the request is sent.
> 
> Obviously it will not solve all very special cases, which people can work
> around with arptables, but it will solve this common one.

I wonder if a change to add a flag preventing *any* packet from being sent
on a NIC which doesn't have the proper source address would be politically
acceptable. I did that type of patch for 2.4.16 to prevent killing
routers by having the MAC change for an IP. It will hurt performance on at
least some routers, and the patch eliminated the problem.

I later changed to using source routing, since the number of IPs was
modest and didn't change, but I am still fighting the issue in a test
environment, where the number of IPs is high and I can't just grab a range
in some cases.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.
