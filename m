From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: e100 + VLANs?
Date: Sat, 08 Oct 2011 18:24:06 +0200
Message-ID: <1318091046.5276.22.camel@edumazet-laptop>
References: <4E90212D.8030009@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60482 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab1JHQYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 12:24:19 -0400
Received: by wwf22 with SMTP id 22so7291940wwf.1
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2011 09:24:18 -0700 (PDT)
In-Reply-To: <4E90212D.8030009@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 08 octobre 2011 =C3=A0 14:08 +0400, Michael Tokarev a =C3=A9c=
rit :
> Yesterday I tried to use 802.1Q VLAN tagging with an (oldish)
> e100-driven network card, identified by lspci like this:
>=20
>  00:12.0 Ethernet controller: Intel Corporation 82557/8/9/0/1 Etherne=
t Pro 100 (rev 02)
>=20
> Just to discover that it does not quite work: packets of
> size 1497+ bytes gets lost.
>=20
> This appears to be a classical problems in this case -
> something forgot to allocate extra 4 bytes for the
> packets.
>=20
> There's at least one bugreport from 2008 (!) about this
> very issue: http://bugs.centos.org/view.php?id=3D2719
> which is still open.
>=20
> The kernel I tried this on was 2.6.32, I checked git log
> for drivers/net/e100.c - there was no changes up to
> current version which may be related to this issue.
>=20
> The question: is this a driver problem or hardware? If
> it's the driver, can it be fixed? And if it's hardware,
> can the driver notify the user somehow - like, by refusing
> to enable VLAN (sub)devices maybe?
>=20
> Yesterday it was actually a bit more complicated for me,
> since the card in question was used to connect to our
> ISP, and they use fixed MAC address per port, so I had
> to find another NIC which is a) able to work with VLAN
> tags properly, and b) is able to change its mac address.
> Lucky I had a VIA RhineIII which does both :)
>=20

Since you have two cards (and probably two machines), maybe you could
try to track if the problem is a bad transmit or a bad receive ?

tcpdump on both machines, and ping -s 2000 from both sides...

e100 driver seems VLAN enabled at a first glance.
