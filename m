From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Intel 82598, RSS and PPPoE
Date: Thu, 28 Jan 2010 16:59:17 +0100
Message-ID: <1264694357.2930.8.camel@edumazet-laptop>
References: <201001281334.51123.alex@wildpark.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alexander Lapidus <alex@wildpark.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:58324 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648Ab0A1P7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 10:59:22 -0500
Received: by bwz27 with SMTP id 27so612633bwz.21
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 07:59:21 -0800 (PST)
In-Reply-To: <201001281334.51123.alex@wildpark.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 28 janvier 2010 =C3=A0 13:34 +0200, Alexander Lapidus a =C3=A9=
crit :
> Hello, everybody!
>  Help is needed in such case. We have a linux-box, running under Cent=
OS 5.4=20
> with a latest kernel. Intel 10 Gigabit AF DA Dual Port Server Adapter=
 (based=20
> on Intel 82598EB) is used for routing purposes. Linux-box is dual CPU=
 Xeon=20
> E5530 server.  Interface eth0 is an uplink to the network core with p=
ure IPv4=20
> trafic on it. Interface eth1 is an downlink to customers. We have 300=
0 802.1q=20
> VLANs on it. PPPoE server daemon is running on all VLAN interfaces. S=
o we have=20
> ethernet frames with 802.1q VLAN tag and PPPoE header incapsulated. O=
ur=20
> problem is with RX packet distribution between rx-queues on this  int=
erface.=20
> All those packets are coming to RX-queue-0. As i understood from Inte=
l=20
> specification on 82598 chipset, problem is with RSS, which can't deco=
de PPPoE=20
> header, so packet is going only to queue 0. My question is how to for=
ce such=20
> packets to spread between different queues. May be it's possible to u=
se VMDq=20
> in this configuration, or any other solution?
>=20
> P.S. We tried this configuration with in-kernel driver and with lates=
t driver=20
> from Intel (ixgbe-2.0.44.14). Situation is the same.
>=20
>=20

What exact linux kernel version are you using ?

If hardware is not able to spread packets into multiple receive queues
because of VLAN or PPOE encapsulation then you might try RPS (not yet
included in kernel) and add appropriate
PPOE decoding in low level frame handling.

RPS v5 pointer : http://www.spinics.net/lists/netdev/msg118378.html


