From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Bogus frames transmitted with r8169 & fragmentation & large mtu
Date: Thu, 16 Feb 2012 00:23:03 +0100
Message-ID: <20120215232303.GB31463@electric-eye.fr.zoreil.com>
References: <20120215163748.GA3998@elliptictech.com> <1329333239.2469.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Bowler <nbowler@elliptictech.com>, netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56984 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457Ab2BOXf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 18:35:29 -0500
Content-Disposition: inline
In-Reply-To: <1329333239.2469.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
> Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 11:37 -0500, Nick Bowler a =C3=
=A9crit :
[...]
> > Let me know if you need any more info,
>=20
> Interesting, but 2nd frame is also corrupted (not at the start but in
> the middle)

And the corruption looks like a packet header. Compare :

0000  00 25 11 8c 1c 3d bc ae  c5 27 19 6f 08 00 45 00   .%...=3D.. .'.=
o..E.
0010  23 24 5d 69 20 00 40 01  46 a5 c0 a8 09 41 c0 a8   #$]i .@. F....=
A..
0020  09 39 08 00 d9 b6 0c 6b  00 01 d1 d2 3b 4f ad 69   .9.....k ....;=
O.i
0030  06 00 42 42 42 42 42 42  42 42 42 42 42 42 42 42   ..BBBBBB BBBBB=
BBB

with :

(lots of 42)
1f00  00 25 11 8c 1c 3d bc ae  c5 27 19 6f 08 00 45 00   .%...=3D.. .'.=
o..E.
1f10  0c 1c 5d 69 0d 26 40 01  70 87 c0 a8 09 41 c0 a8   ..]i.&@. p....=
A..
                 (^^^^^ fragment offset 6694)
1f20  09 39 42 42 42 42 42 42  42 42 42 42 42 42 42 42   .9BBBBBB BBBBB=
BBB

Mac addresses and ip addresses match.

Hayes, what is the story with ICMP packets and IP flags ?

--=20
Ueimor
