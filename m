From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] latest net-next-2.6 doesnt fly
Date: Sun, 04 Apr 2010 11:29:55 +0200
Message-ID: <1270373395.1971.13.camel@edumazet-laptop>
References: <1270200783.1989.4.camel@edumazet-laptop>
	 <1270201248.1989.8.camel@edumazet-laptop>
	 <1270202304.1989.14.camel@edumazet-laptop>
	 <20100404181542N.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:63741 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250Ab0DDJcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 05:32:41 -0400
Received: by bwz1 with SMTP id 1so2296085bwz.21
        for <netdev@vger.kernel.org>; Sun, 04 Apr 2010 02:32:40 -0700 (PDT)
In-Reply-To: <20100404181542N.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 04 avril 2010 =C3=A0 18:16 +0900, FUJITA Tomonori a =C3=A9c=
rit :
> > +			return 0;
>=20
> Sorry about that and thanks for the fix.
>=20
> I think, if pdev is null, returning 1 here is safer since the device
> doesn't set up dma info properly.
>=20
> Do you know what device hits this bug? You said that you use bnx2 and
> tg3. Both call SET_NETDEV_DEV with pdev->dev. I tested bnx2 and seems
> that netdev->dev.parent is set up correctly.
> --

Might be because of my setup, I suspect I had two reasons to hit the
bug :

A bonding of eth2 (bnx2) and eth3 (tg3)

Then vlans on top of this bond0

When first dev_queue_xmit() was called, it was for a virtual device :)

# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP
qlen 1000
    link/ether 00:1e:0b:ec:d3:dc brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq
master bond0 state UP qlen 1000
    link/ether 00:1e:0b:ec:d3:d2 brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc hfsc
master bond0 state UP qlen 1000
    link/ether 00:1e:0b:ec:d3:d2 brd ff:ff:ff:ff:ff:ff
5: eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:1e:0b:92:78:51 brd ff:ff:ff:ff:ff:ff
6: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc
noqueue state UP=20
    link/ether 00:1e:0b:ec:d3:d2 brd ff:ff:ff:ff:ff:ff
7: vlan.103@bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500
qdisc pfifo_fast state UP qlen 100
    link/ether 00:1e:0b:ec:d3:d2 brd ff:ff:ff:ff:ff:ff
8: vlan.825@bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500
qdisc pfifo_fast state UP qlen 1000
    link/ether 00:1e:0b:ec:d3:d2 brd ff:ff:ff:ff:ff:ff


