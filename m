From: Chris Siebenmann <cks@cs.toronto.edu>
Subject: Re: Bug? GRE tunnel periodically won't transmit some packets
Date: Tue, 08 Nov 2011 02:08:19 -0500
Message-ID: <20111108070819.C643236221@apps0.cs.toronto.edu>
References: <1320734606.8976.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Siebenmann <cks@cs.toronto.edu>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:34470 "EHLO
	cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314Ab1KHHIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 02:08:20 -0500
In-reply-to: eric.dumazet's message of Tue, 08 Nov 2011 07:43:26 +0100.
             <1320734606.8976.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| Le mardi 08 novembre 2011 =C3=A0 01:17 -0500, Chris Siebenmann a =C3=A9=
crit :
| > | Le lundi 07 novembre 2011 =C3=A0 11:21 -0500, Chris Siebenmann a =
=C3=A9crit :
| > | > I have a weird problem where a GRE tunnel periodically won't tr=
ansmit
| > | > some (TCP) packets, while at the same time it will transmit oth=
ers just
| > | > fine. This is happening in the current kernel.org git head kern=
el as
| > | > well as earlier ones.
| > [...]
| > | Do you have any errors on :
| > |=20
| > | ip -s -d link show dev greXXXX
| >=20
| >  I do indeed. When the problem is happening, I see TX errors counti=
ng
| > up one-for-one with packets that are not transmitted (and no RX
| > errors). Otherwise I don't see any errors. The other end of the GRE
| > tunnel shows no errors (TX or RX).
[..]
| OK, but could you please report the exact "ip -s -d link gre..."
| output ?

Sure. Here it is:

7: extun: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1200 qdisc noqueue state =
UNKNOWN=20
    link/gre 66.96.18.208 peer 128.100.3.58
    gre remote 128.100.3.58 local 66.96.18.208 dev ppp0 ttl inherit=20
    RX: bytes  packets  errors  dropped overrun mcast  =20
    2793721    17015    0       0       0       0     =20
    TX: bytes  packets  errors  dropped carrier collsns=20
    2242148    26824    18      0       0       0     =20

(The packet and byte counts were much lower when the problem happened;
this time around it happened relatively soon after I rebooted my machin=
e
and brought up the PPPoE and GRE links, but hasn't happened since and
I've been using the GRE link.)

=46or vaguely historical reasons I don't use 'greXXX' as the name of
the GRE tunnel. I have a 'gre0' device, but it is not up. In case it
matters, its output is:

6: gre0: <NOARP> mtu 1476 qdisc noop state DOWN=20
    link/gre 0.0.0.0 brd 0.0.0.0
    gre remote any local any ttl inherit nopmtudisc=20
    RX: bytes  packets  errors  dropped overrun mcast  =20
    0          0        0       0       0       0     =20
    TX: bytes  packets  errors  dropped carrier collsns=20
    0          0        0       0       0       0     =20

 Let me know if you want a full dump of 'ip link show' (with or
without verbosity).

	- cks
