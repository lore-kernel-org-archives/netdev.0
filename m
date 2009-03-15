From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: IGMP Join dropping multicast packets
Date: Sun, 15 Mar 2009 03:37:09 +0100
Message-ID: <49BC69D5.5000002@cosmosbay.com>
References: <91bdcedb0903141316j2dbf4160wb348a5a9e3bde8ad@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dave Boutcher <daveboutcher@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41318 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753082AbZCOChS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 22:37:18 -0400
In-Reply-To: <91bdcedb0903141316j2dbf4160wb348a5a9e3bde8ad@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Boutcher a =E9crit :
> I'm running into an interesting problem with joining multiple
> multicast feeds.  If you join multiple multicast feeds using
> setsockopt(...,IP_ADD_MEMBERSHIP...) it causes packets on UNRELATED
> multicast feeds to get dropped.  We have a multicast feed on a rock
> solid network, and we were very surprised to see dropped packets.  Th=
e
> cause was a different process/program being run by a different user
> joining a bunch of mulitcast feeds.
>=20
> I can recreate this with a fairly simple testcase (attached below.)
> The problem doesn't happen with unicast UDP data, and it doesn't
> happen with loopback, so you need at least two systems to run this
> (and what subscriber to netdev doesn't have at least two systems.)  T=
o
> recreate, run "receiver" on one system, "sender", on another, and the=
n
> "joiner" on the receiving system.  You should see a message pop out
> saying that packets have been dropped.  I've recreated this on a few
> different kernel versions (the latest being 2.6.28) and a few
> different sets off hardware.  I HAVEN"T recreated it if the system
> doing the IP_ADD_MEMBERSHIP specifies a specific interface rather tha=
n
> INADDR_ANY.  I'm not sure if that is core to the issue or not.  You
> may also need to bump the value in
> /proc/sys/net/ipv4/igmp_max_memberships (though that hasn't seemed
> necessary for me.)
>=20
> I poked around in igmp.c, but its mojo exceeds my threshold.  If
> anyone has any ideas or questions I'd be happy to hear them.
>=20

I could not reproduce the problem on my machines (bnx2 adapter), even i=
f changing
NUMSOCK from 55 to 200 in joiner.c

Is your network a 100Mb one or Gigabit ?
Try to slow down your joiner ?
(Could be a flood of IGMP messages your router/switch cannot cope with)

Please describe your "rock solid" network setup (kind of network adapte=
rs you have, kind of router...)

Each time an address is added, NIC driver have to reprogram mcfilter of
the device. Maybe some NIC can drop some packets at this moment...

If using tcpdump to force promiscuous mode on the device also triggers =
packet losses ?

(see also ifconfig ethX promisc|allmulti)

