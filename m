From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: e100 + VLANs?
Date: Tue, 11 Oct 2011 14:04:34 +0200
Message-ID: <1318334674.2538.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E90212D.8030009@msgid.tls.msk.ru>
		<1318091046.5276.22.camel@edumazet-laptop>	<4E9097C0.2030307@gmail.com>
		<20111010101954.GB2840382@jupiter.n2.diac24.net>
		<4E9307CB.4050704@msgid.tls.msk.ru>
		<1318259152.3227.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
		<20111010151343.GB3260852@jupiter.n2.diac24.net>
		<4E932278.8010802@tls.msk.ru>	<4E941198.9000307@msgid.tls.msk.ru>
	 <CAL4WiiphpyizVaNkvOdJp1+UK53TkGw9RXnC-vzH7fTNpBAAEA@mail.gmail.com>
	 <4E942F8A.90205@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Lamparter <equinox@diac24.net>, jeffrey.t.kirsher@intel.com,
	netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:61692 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285Ab1JKMES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 08:04:18 -0400
Received: by eye27 with SMTP id 27so2441278eye.19
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 05:04:17 -0700 (PDT)
In-Reply-To: <4E942F8A.90205@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 11 octobre 2011 =C3=A0 15:59 +0400, Michael Tokarev a =C3=A9cr=
it :

> Hmm.  This does not _exactly_ work.
>=20
> I applied it on top of 2.6.32, patch applied but with some fuzz - I c=
hecked
> manually and it appears to be ok.
>=20
> Now, with this patch applied, I see on the e100 side:
>=20
> 00:1f:c6:ef:e5:1b > 00:90:27:30:6d:1c, ethertype 802.1Q (0x8100), len=
gth 1504: vlan 6, p 0, ethertype IPv4, truncated-ip - 1 bytes missing! =
(tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto ICMP (1), length 14=
87)
>     10.48.6.1 > 10.48.6.2: ICMP echo request, id 27613, seq 6, length=
 1467
>=20
> when pinging it with -s 1459 (1487 total size).
>=20
> I added extra +40 for RFD_BUF_LEN define and recompiled
> (this resulted in RFD_BUF_LEN=3D1560, - I've added a printk
> just to be sure).
>=20
> Now I see the same effect as before the patch:  maximum
> packet size that goes and can be seen on the e100 side
> is 1468(1496) (ping), which results in this on e100 side:
>=20
> 15:54:44.830941 00:1f:c6:ef:e5:1b > 00:90:27:30:6d:1c, ethertype 802.=
1Q (0x8100), length 1514: vlan 6, p 0, ethertype IPv4, (tos 0x0, ttl 64=
, id 0, offset 0, flags [DF], proto ICMP (1), length 1496)
>     10.48.6.1 > 10.48.6.2: ICMP echo request, id 28735, seq 4, length=
 1476
> 15:54:44.831025 00:90:27:30:6d:1c > 00:1f:c6:ef:e5:1b, ethertype 802.=
1Q (0x8100), length 1514: vlan 6, p 0, ethertype IPv4, (tos 0x0, ttl 64=
, id 12010, offset 0, flags [none], proto ICMP (1), length 1496)
>     10.48.6.2 > 10.48.6.1: ICMP echo reply, id 28735, seq 4, length 1=
476
>=20
> (and it works).  With -s 1469, no ICMP packets can be seen
> on e100 side.
>=20
> So it still may be the hardware... :)

Yes, my patch was not needed, I was not sure sizeof(struct rfd) was
included or not in the rfd.size setting (apparently its not needed)

Any counters increase in "ethtool -S eth0" ?
