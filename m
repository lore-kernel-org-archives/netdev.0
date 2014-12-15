From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery stalls on v3.
Date: Mon, 15 Dec 2014 19:04:43 +0100
Message-ID: <2044516.PfymfTnqxW@h2o.as.studentenwerk.mhn.de>
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
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:58585 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750772AbaLOSEq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2014 13:04:46 -0500
In-Reply-To: <1418429740.13491.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric!

Am Freitag, 12. Dezember 2014, 16:15:40 schrieb Eric Dumazet:
> On Sat, 2014-12-13 at 00:47 +0100, Wolfgang Walter wrote:
> > I can't disable it as the driver will not allow it:
> > # ethtool -K eth0 tx off
> > Cannot change tx-checksumming
> > Could not change any device features
>=20
> Sounds a bug in itself :(

I think the "gso disabled for interface" case is broken because:

tcp_sendmsg() sets tcp_gso_segs to zero

tcp_sendmsg() calls tcp_push_one() or __tcp_push_pending_frames()

tcp_push_one() and  __tcp_push_pending_frames() call tcp_write_xmit()

tcp_write_xmit() call tcp_init_tso_segs()

tcp_init_tso_segs() calls tcp_set_skb_tso_segs() because !tso_segs is t=
rue

tcp_init_tso_segs() creates a gso-packet if packet size is larger than=20
mss_now.


I think tcp_init_tso_segs() assumed that tcp_init_tso_segs() checks if =
the=20
socket supports gso.

I didn't check the other callers of tcp_init_tso_segs().


Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
