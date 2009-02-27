From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Marvell 88E609x switch?
Date: Fri, 27 Feb 2009 16:52:24 +0100
Message-ID: <20090227155224.GK17040@xi.wantstofly.org>
References: <20090227144004.GC17040@xi.wantstofly.org> <49A7FEE1.2020705@mlbassoc.com> <20090227145746.GD17040@xi.wantstofly.org> <49A801E6.1040502@mlbassoc.com> <20090227151441.GE17040@xi.wantstofly.org> <49A80606.1040508@mlbassoc.com> <20090227152721.GG17040@xi.wantstofly.org> <49A806C5.1010200@mlbassoc.com> <20090227153102.GH17040@xi.wantstofly.org> <49A80A75.8000101@mlbassoc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Gary Thomas <gary@mlbassoc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:51400 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754012AbZB0Pw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 10:52:26 -0500
Content-Disposition: inline
In-Reply-To: <49A80A75.8000101@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 08:44:53AM -0700, Gary Thomas wrote:

> >>>>> IP addresses should be attached to the lanX.X interfaces, not to eth0
> >>>>> -- eth0 will only be carrying specially tagged (DSA/EDSA) packets.
> >>>>> So you should move the IP address to lan1.1.
> >>>>>
> >>>>> Can you trying pinging via lan1.1 and then seeing if there are
> >>>>> packets transmitted out over eth0, and dump those packets with tcpdump?
> >>>> It looks like the packets are going out, but I don't see anything
> >>>> on the wire.  After a few ping attempts:
> >>>>
> >>>> root@ppc_target:~ ifconfig
> >>>> eth0      Link encap:Ethernet  HWaddr 00:1D:11:81:00:00
> >>>>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >>>>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
> >>>>           TX packets:41 errors:0 dropped:0 overruns:0 carrier:0
> >>>>           collisions:0 txqueuelen:1000
> >>>>           RX bytes:0 (0.0 B)  TX bytes:2974 (2.9 KiB)
> >>>>           Base address:0x6000
> >>>>
> >>>> lan1.1    Link encap:Ethernet  HWaddr 00:1D:11:81:00:00
> >>>>           inet addr:192.168.12.189  Bcast:192.168.12.255  Mask:255.255.255.0
> >>>>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >>>>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
> >>>>           TX packets:39 errors:0 dropped:0 overruns:0 carrier:0
> >>>>           collisions:0 txqueuelen:0
> >>>>           RX bytes:0 (0.0 B)  TX bytes:1638 (1.5 KiB)
> >>>>
> >>>> The eth0 and lan1.1 counters are going up at more or less the
> >>>> same rate.
> >>> Can you run tcpdump on eth0 to see what the packets look like?
> >> Locally (on the board with the switch)?  That will take a while to
> >> set up as it's a 100% embedded system, runs from FLASH, etc.
> 
> Here's the result of 'tcpdump -i eth0' while pinging:
> 
> PING 192.168.12.18 (192.168.12.18): 56 data bytes
> 15:52:34.718207 00:1d:11:81:00:00 (oui Unknown) > Broadcast, ethertype Unknown (0x4000), length 46:
>         0x0000:  0000 0806 0001 0800 0604 0001 001d 1181  ................
>         0x0010:  0000 c0a8 0ca8 0000 0000 0000 c0a8 0c12  ................
> 15:52:35.717893 00:1d:11:81:00:00 (oui Unknown) > Broadcast, ethertype Unknown (0x4000), length 46:
>         0x0000:  0000 0806 0001 0800 0604 0001 001d 1181  ................
>         0x0010:  0000 c0a8 0ca8 0000 0000 0000 c0a8 0c12  ................
> 
> I also tried pinging in from the outside, but didn't see any
> packets.  I would assume that I'd see at least broadcast/ARP
> packets.

Can you dump the entire packet (-s 2000) including the ethernet
headers and all (-eeexxxvvvnnn or so)?


> > OK, do you have ethtool then?  If yes, can you run ethtool on the
> > lan1.1 interface to see if any of the hardware (switch chip) TX
> > counters are increasing?
> 
> I'm not familiar with that tool (I did install it).  What
> option (of the *many*) are you interested in?

"ethtool -S lan1.1", please.

Perhaps we should take this off-list..
