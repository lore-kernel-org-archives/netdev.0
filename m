From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 1/9] net/mlx4_core: Enforce irq affinity
 changes immediatly
Date: Sat, 17 May 2014 21:33:07 +0100
Message-ID: <1400358787.2647.65.camel@deadeye.wl.decadent.org.uk>
References: <1399880605-28772-1-git-send-email-amirv@mellanox.com>
	 <1399880605-28772-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-YmaTi4/OU78Xmk39r0+8"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53709 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751461AbaEQUdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2014 16:33:18 -0400
In-Reply-To: <1399880605-28772-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YmaTi4/OU78Xmk39r0+8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-05-12 at 10:43 +0300, Amir Vadai wrote:
> From: Yuval Atias <yuvala@mellanox.com>
>=20
> During heavy traffic, napi is constatntly polling the complition queue
> and no interrupt is fired. Because of that, changes to irq affinity are
> ignored until traffic is stopped and resumed.
>=20
> By registering to the irq notifier mechanism, and forcing interrupt when
> affinity is changed, irq affinity changes will be immediatly enforced.
[...]

This somewhat breaks ARFS in your driver, as that depends on IRQ
affinity notification.

It is also not safe to put an IRQ affinity notification function in a
module currently, as the work item for notification doesn't carry a
module reference and could be called after the module is removed.

Ben.

--=20
Ben Hutchings
I'm not a reverse psychological virus.  Please don't copy me into your sig.

--=-YmaTi4/OU78Xmk39r0+8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU3fHh+e/yOyVhhEJAQqO4g//ZMWfEW9Ik5Vs1ur+te/yE7Fwt8DJFhx4
QnetsZP3jkOB9gYYJJ1xSLcNmpJyVRM47rzZXTP1Rr5LS64v16j1MqTpQHxMwewo
g7gPDLxcMlitc7Z3gJaLN1aYe+B4FromDVHrPXwltSGxjmtfvxnkLnAqUMxU4jGI
Jq0OoveaBmvlXYoPSwTwLjaRFlOMUxleSjCF0DGfP3Aicot+crKTklgP6sogG+sH
G2agtZkvC4zalIKdIPkqVtzA4GXDRuMDTax1LYM2VC0yS5CeQqny+AtmjYb1uEVR
BQZAi51oxihaasNxOXngueXrNIuvl2iDikmUL67TGb44TsQJDas2FApvgXZ1Jm4n
wAyOMjPVaV1iSfEoO3ihjd8OwI5hOq2duX/n5RRzcmXN+2G9zvsJIzP9fzPXhY2F
8SwIiqOuWE65df27om5xKyhb4z9p1C73gqtFEIqgTVmB1L8uNtfTCutYSUjr/Noa
nYe8DM0KLjU/IntZaAb89exqhVYH2wKt9i1Rm9Xd4Ydt5HU4/RwmuFZm3UxTakRt
B/r3Yfw6Ka0P1MI5dD0M2rM9rtejszkcQNtQ/sA4JYdAWU0SLOebR5VuquIweaXm
CTCh7u89vmqo/di5y4zmXVDCm0T4QrlJqs5vTJPa3XfddGB9JxDwwi14FOX4NG33
AYB2BqdeoOc=
=krIK
-----END PGP SIGNATURE-----

--=-YmaTi4/OU78Xmk39r0+8--
