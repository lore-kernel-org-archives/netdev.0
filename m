From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery stalls on v3.
Date: Sat, 13 Dec 2014 01:43:05 +0100
Message-ID: <2722132.FiOmuVe0fZ@h2o.as.studentenwerk.mhn.de>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n> <1500356.bBOpW4o4zG@h2o.as.studentenwerk.mhn.de> <1418429740.13491.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:49310 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932140AbaLMAnI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2014 19:43:08 -0500
In-Reply-To: <1418429740.13491.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 12. Dezember 2014, 16:15:40 schrieb Eric Dumazet:
> On Sat, 2014-12-13 at 00:47 +0100, Wolfgang Walter wrote:
> > I can't disable it as the driver will not allow it:
> > # ethtool -K eth0 tx off
> > Cannot change tx-checksumming
> > Could not change any device features
>=20
> Sounds a bug in itself :(
>=20

Yes, that is what I meant in my email that there seems also to be bug i=
n the=20
GSO path.


I don't understand how tcp_sendmsg() marks gso/non-gso skbs.

tcp_send_mss() calls tcp_xmit_size_goal() which calls tcp_xmit_size_goa=
l() and=20
there is a check for GSO ( sk_can_gso(sk) ). If sk_can_gso() returns fa=
lse=20
then tcp_xmit_size_goal() returns mss_now. gso_segs seems to be set to =
zero.=20
In in tcp_output.c gso_segs =3D=3D 0 seems to allow GSO.

What if mss later shrinks? Couldn't it be that then tcp_set_skb_tso_seg=
s()=20
gets called and then there the gso branch is taken?

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
