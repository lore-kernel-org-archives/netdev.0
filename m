From: Tom Parkin <tparkin@katalix.com>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Thu, 28 Jun 2012 09:24:58 +0100
Message-ID: <20120628082457.GA2507@raven>
References: <1340823810.26242.81.camel@edumazet-glaptop>
 <4FEB6B64.5060708@hp.com>
 <1340829541.26242.90.camel@edumazet-glaptop>
 <20120627135034.7db7d0eb@nehalam.linuxnetplumber.net>
 <4FEB73EF.9090702@candelatech.com>
 <1340832022.26242.131.camel@edumazet-glaptop>
 <4FEB7BB9.1080905@candelatech.com>
 <1340832947.26242.169.camel@edumazet-glaptop>
 <4FEB90C3.9050607@hp.com>
 <1340859654.26242.201.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wac7ysb48OaltWcw"
Cc: Rick Jones <rick.jones2@hp.com>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, David.Laight@ACULAB.COM,
	James Chapman <jchapman@katalix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:51970 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752197Ab2F1IZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2012 04:25:03 -0400
Content-Disposition: inline
In-Reply-To: <1340859654.26242.201.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 28, 2012 at 07:00:54AM +0200, Eric Dumazet wrote:
> [1] : LLTX drivers case=20
>    since ndo_start_xmit() can be run concurrently by many cpus, safely
> updating an "unsigned long" requires additional hassle :
>=20
>    1) Use of a spinlock to protect the update.
>    2) Use atomic_long_t instead of "unsigned long"
>    3) Use percpu data
>=20
> 3) is overkill for devices with light traffic, because it consumes lot
> of RAM on machines with 2048 possible cpus, _and_ the reader must fold
> the data of all possible values.

Thanks Eric.

So am I right in thinking that a v3 patch which uses atomic_long_t for
the statistics would be the correct way forwards?

--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--wac7ysb48OaltWcw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJP7BTZAAoJEJSMBmUKuovQbhoH/iX0jcT3MiueDTHZLsCvZQhL
xOeArPdq7SXGIfyo61/hrjdh3hotjNQe7jiauYG9SJzxTXRYr+FGrz2uLcaSXSD9
Fx5VDIPGsGMDo1HA+mQjGhGCgFDYR4Twm1PHMwjDaNJvsM3sJx3BWIlOEFu3Y7G/
eI3jIzcjpWqUBy0FAkLC0Qnmxnc4BS/UpMu3/fEn4pvsBrDgENvzBOz7UfEfNPnf
Zj4f/ReDxkq9nWmjjhbw+c8dhd4JUzGnIuoqH9OccS8y66zGkSzUvYyyoBiu3ZNd
D7Tf34VmxJO7CcNeBMhMOS7IXLU0wvbJwQ0VBZyKj7+G9e1iMy/3yQouoXuv/h4=
=wQNb
-----END PGP SIGNATURE-----

--wac7ysb48OaltWcw--
