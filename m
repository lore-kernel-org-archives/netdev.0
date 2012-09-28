From: Nolwenn <donolwenn@gmail.com>
Subject: Re: Possible bug with r8169 driver
Date: Fri, 28 Sep 2012 06:47:06 +0000
Message-ID: <1478421.GOy9qdQlkG@bureau>
References: <2197741.c8FeV4Xbis@bureau> <20120927222147.GA29047@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hayeswang <hayeswang@realtek.com>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:52897 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152Ab2I1GrM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 02:47:12 -0400
Received: by weyt9 with SMTP id t9so1109854wey.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 23:47:11 -0700 (PDT)
In-Reply-To: <20120927222147.GA29047@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 28 septembre 2012 00:21:47 Francois Romieu a =C3=A9crit :

> Can you send an 'ip -s link' before any ipv6 traffic flows, then
> after ?
>=20

Before ipv6 traffic

% ip -s link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
mode DEFAULT=20
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    RX: bytes  packets  errors  dropped overrun mcast  =20
    0          0        0       0       0       0     =20
    TX: bytes  packets  errors  dropped carrier collsns=20
    0          0        0       0       0       0     =20
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast st=
ate=20
UP mode DEFAULT qlen 1000
    link/ether 30:85:a9:ee:43:fa brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast  =20
    2607155    2232     0       0       0       0     =20
    TX: bytes  packets  errors  dropped carrier collsns=20
    142314     1725     0       0       0       0

During tcpdump interception

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
mode DEFAULT=20
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    RX: bytes  packets  errors  dropped overrun mcast  =20
    0          0        0       0       0       0     =20
    TX: bytes  packets  errors  dropped carrier collsns=20
    0          0        0       0       0       0     =20
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast st=
ate=20
UP mode DEFAULT qlen 1000
    link/ether 30:85:a9:ee:43:fa brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast  =20
    4191544    4587     0       0       0       0     =20
    TX: bytes  packets  errors  dropped carrier collsns=20
    268787     3317     0       0       0       0=20

After set set eth0 in promisc mode

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
mode DEFAULT=20
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    RX: bytes  packets  errors  dropped overrun mcast  =20
    0          0        0       0       0       0     =20
    TX: bytes  packets  errors  dropped carrier collsns=20
    0          0        0       0       0       0     =20
2: eth0: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc=20
pfifo_fast state UP mode DEFAULT qlen 1000
    link/ether 30:85:a9:ee:43:fa brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast  =20
    10301337   12212    0       0       0       0     =20
    TX: bytes  packets  errors  dropped carrier collsns=20
    803894     9309     0       0       0       0=20

> > % dmesg | grep r8169
> >=20
> > [    1.810423] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> > [    1.810548] r8169 0000:03:00.0: irq 44 for MSI/MSI-X
> > [    1.810671] r8169 0000:03:00.0: eth0: RTL8168f/8111f at
> > 0xffffc900057ae000, 30:85:a9:ee:43:fa, XID 08000800 IRQ 44 [    1.8=
10672]
> > r8169 0000:03:00.0: eth0: jumbo features [frames: 9200 bytes, tx
> > checksumming: ko]
> Hayes, is there by any luck something different for the 8168f regardi=
ng
> the layout of the multicast filtering registers ?

I don't have sufficient skills in networks to understand what do you me=
an,=20
sorry. Any command line, files comparing to get the information?
