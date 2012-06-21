From: Tom Parkin <tparkin@katalix.com>
Subject: Re: [PATCH] l2tp: synchronise u64 stats writer callsites
Date: Thu, 21 Jun 2012 17:19:56 +0100
Message-ID: <20120621161955.GA29812@jackdaw>
References: <1340291054-16077-1-git-send-email-tparkin@katalix.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6F5D@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="opJtzjQTFsWo+cga"
Cc: netdev@vger.kernel.org, James Chapman <jchapman@katalix.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:54307 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759701Ab2FUQT6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2012 12:19:58 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F5D@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 21, 2012 at 04:18:12PM +0100, David Laight wrote:
> The purpose of the u64_stats_update_begin/end is to
> perform lockless writes of the stats.
> If you need to lock them (because multiple threads can
> be writing to stats covered by the same 'syncp' at the
> same time) then the reader might as well use the same lock.
>=20
> Otherwise split the 'syncp' such that only one update
> can be happening (for each sync).

Thanks David.

I think the best approach is probably to attempt to partition the l2tp
statistics such that we can be sure of single-threaded writer access
for each dataset, which can then be covered by a 'syncp'.

If that turns out not to be possible, I suppose the fallback position
is to do away with the u64_stats_update* calls and just use a spinlock
instead.

I'll look at implementing the former and put a new patch together.

Tom
--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--opJtzjQTFsWo+cga
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJP40mrAAoJEJSMBmUKuovQNsYH/2ewZwJIjs+w3odNBihU3TlJ
gFntKzZo5NpUkmDr3sxCRrOwGDv+d3ZJj0pCOcPuT0OqaWJIiYFt2vQid/Gib9TH
Yp3CDaiWiTsQXjXqyAM8jYt2ObPh5EZeIaInFSXGjMWAFkQNbIQR449o/WflSTSO
ADn0lUdGVILCnDTZ/DXKlNV0EGBzzjp/PGUt/sRi63F6K1/L/dXtxkeB5DLK8GOs
7UvEtxFl1LeJR1Q1nfoPL54C2lmZvAUqtJIgOtgGk0ZXk18elTCas/6dA3celfut
H2M9AHk83U/obBPUfj4YTZx7zsXW98sBA8mINYg2BANuPBls59KS05ZdgGz9ChY=
=wT95
-----END PGP SIGNATURE-----

--opJtzjQTFsWo+cga--
