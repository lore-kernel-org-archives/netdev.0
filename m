From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Regression in bonding between 2.6.26.8 and 2.6.27.6
Date: Tue, 18 Nov 2008 12:53:39 -0800
Message-ID: <17409.1227041619@death.nxdomain.ibm.com>
References: <491FEAD5.4090205@krogh.cc> <17663.1226965523@death.nxdomain.ibm.com> <49232489.4000504@krogh.cc>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:36244 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752671AbYKRUyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 15:54:17 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mAIKrjkZ010374
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 13:53:45 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAIKs62k069320
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 13:54:10 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAIKs4lH025071
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 13:54:04 -0700
In-reply-to: <49232489.4000504@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh <jesper@krogh.cc> wrote:

>Jay Vosburgh wrote:
[...]
>> 	What exactly does "doesn't get up" mean? 
>
>Looks like this:
># ifconfig bond0
>bond0     Link encap:Ethernet  HWaddr 00:1e:68:57:82:b2
>          inet6 addr: fe80::21e:68ff:fe57:82b2/64 Scope:Link
>          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
>          RX packets:74 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:17 errors:0 dropped:0 overruns:0 carrier:0
>          collisions:0 txqueuelen:0
>          RX bytes:5952 (5.8 KB)  TX bytes:1900 (1.8 KB)
>
>(usually this would have been assigned an ip-address using dhcp, does that
>with 2.6.26.8, with the same configuration). Manually running dhclient on
>the interface doesn't bring it up either.

	For this case, when there's a non-zero HWaddr assigned, what is
in /proc/net/bonding/bond0 and what bonding related messages are in
dmesg or /var/log/messages?

[...]
>Booting up with static ip configuration it looks like this:
>
># ifconfig
>bond0     Link encap:Ethernet  HWaddr 00:00:00:00:00:00 
>
>          inet addr:10.194.132.90  Bcast:10.194.133.255 Mask:255.255.254.0
>          UP BROADCAST MASTER MULTICAST  MTU:1500  Metric:1 
>          RX packets:0 errors:0 dropped:0 overruns:0 frame:0 
>          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0 
>          collisions:0 txqueuelen:0 
>          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>
>Apparently correct, but absolutely no traffic can go through the interface.

	This is different, and not correct: there's no HWaddr.  That
probably means there are no slaves.  This is most likely a totally
separate problem; the first information suggests that the bond has
slaves, but isn't working; this suggests that the bond has no slaves
(which is why it won't work).

>Configured with a static ip. ifconfig claims that the interface is up and
>configured with the ip-address.
>
># cat /proc/net/bonding/bond0
>Ethernet Channel Bonding Driver: v3.3.0 (June 10, 2008)
>
>Bonding Mode: IEEE 802.3ad Dynamic link aggregation
>Transmit Hash Policy: layer2 (0)
>MII Status: down
>MII Polling Interval (ms): 100
>Up Delay (ms): 0
>Down Delay (ms): 0
>
>802.3ad info
>LACP rate: slow
>bond bond0 has no active aggregator
>
># ifconfig bond0
>bond0     Link encap:Ethernet  HWaddr 00:00:00:00:00:00
>          inet addr:10.194.132.90  Bcast:10.194.133.255  Mask:255.255.254.0
>          UP BROADCAST MASTER MULTICAST  MTU:1500  Metric:1
>          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>          collisions:0 txqueuelen:0
>          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

	As with the prior information, the above indicates that there
are no slaves attached to the bond.  There's no HWaddr, and the
/proc/net/bonding/bond0 lists no slaves.

	For this case (bonding HWaddr all zeros), what does dmesg or
/var/log/messages list for bonding?  This is most likely some kind of
configuration problem causing no interfaces to be enslaved.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
