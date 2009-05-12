From: Yury Polyanskiy <ypolyans@Princeton.EDU>
Subject: Re: [IPSEC] xfrm_state locking problem in xfrm_input.c
Date: Tue, 12 May 2009 00:05:16 -0400
Message-ID: <20090512000516.32589e1f@penta.localdomain>
References: <20090511184739.6e497f29@penta.localdomain>
	<20090512034813.GA25841@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/PCQgfpjIIvLAYx2mcQW/wCC"; protocol="application/pgp-signature"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postoffice03.Princeton.EDU ([128.112.131.174]:55057 "EHLO
	Princeton.EDU" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750709AbZELEHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 00:07:34 -0400
In-Reply-To: <20090512034813.GA25841@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/PCQgfpjIIvLAYx2mcQW/wCC
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 12 May 2009 13:48:13 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, May 11, 2009 at 06:47:39PM -0400, Yury Polyanskiy wrote:
> > xfrm_input() code uses spin_lock() where it must be using
> > spin_lock_bh() instead. The corresponding code in xfrm_output.c
> > correctly uses spin_lock_bh().=20
> >=20
> > Note that if the locally generated packet is sent to a local ip,
> > dev_queue_xmit() calls loopback_xmit() and the xfrm_input() will be
> > called with softirqs enabled.
>=20
> dev_queue_xmit always disables BH before calling the device xmit
> function.  So how can this happen?
>=20

Oops, you right. Thanks for the explanation!

YP

--Sig_/PCQgfpjIIvLAYx2mcQW/wCC
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkoI9XwACgkQemuRe3zuqOQB3ACeImnUyUIPIGDLDTFRsI/q2Lwl
t3AAoLW9d35oe5VpPus2WN0F17Zhg0G5
=2FYF
-----END PGP SIGNATURE-----

--Sig_/PCQgfpjIIvLAYx2mcQW/wCC--
