From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: TCP stalls in current git, possibly splice related
Date: Wed, 18 Jul 2007 00:36:10 +0200
Message-ID: <1184711770.4658.5.camel@johannes.berg>
References: <Line.LNX.4.64.0707121608100.10773@d.namei>
	 <1184320965.30334.2.camel@johannes.berg> <20070713110534.GF5328@kernel.dk>
	 <1184575545.15112.0.camel@johannes.berg>  <20070716120247.GG5195@kernel.dk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-vLWfzIkMdgAMbeIPz0ln"
Cc: James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:40414 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756638AbXGRKKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 06:10:51 -0400
In-Reply-To: <20070716120247.GG5195@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-vLWfzIkMdgAMbeIPz0ln
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-07-16 at 14:02 +0200, Jens Axboe wrote:

> Yep, it's a sender thing, so upgrading the receiver will not change
> anything.

Ok, I upgraded, but that didn't help. And in fact, I don't see how it
could have since synergy doesn't use splice or sendfile. I should've
thought of that right away, sorry.

It seems that packets are actually coming in during the time that my
mouse hangs though (ran wireshark in parallel and saw no pauses in the
timeline.) Hence, it actually seems to be on the receiver side, and
running the synergy client under strace reveals that during the time my
mouse hangs it's in poll() waiting for input on the tcp socket. sysrg-t
doesn't show anything useful, it's just scheduling waiting for data.
According to wireshark data is sent, but it never shows up at the
application layer.

johannes

--=-vLWfzIkMdgAMbeIPz0ln
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGnURa/ETPhpq3jKURAm9bAJ0V5CHlnZaGhiWs0HfcbG8k/nCz6ACgqVsE
/q/3GOgGZKI83nOdJtPAxJE=
=yxDX
-----END PGP SIGNATURE-----

--=-vLWfzIkMdgAMbeIPz0ln--

