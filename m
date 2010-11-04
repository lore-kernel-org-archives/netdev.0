From: Michael Ellerman <michael@ellerman.id.au>
Subject: Freeing alive fib_info caused by ebc0ffae5
Date: Thu, 04 Nov 2010 21:23:06 +1100
Message-ID: <1288866186.30549.10.camel@concordia>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-uEgXX4doiXHynHoq4zge"
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44918 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752550Ab0KDKXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Nov 2010 06:23:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-uEgXX4doiXHynHoq4zge
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi all,

I'm running Linus' latest or thereabouts (ff8b16d), and I'm seeing
"Freeing alive fib_info" messages, from free_fib_info().

Actually I only get one per boot, when network interfaces come up.
Seemingly related I am getting refcount problems when I shutdown, ie.
unregister_netdevice() sees a usage count of 1, which never decrements.

Bisect says it's ebc0ffae5 which causes the problem, or makes it appear.

    fib: RCU conversion of fib_lookup()
   =20
    fib_lookup() converted to be called in RCU protected context, no
    reference taken and released on a contended cache line (fib_clntref)
   =20

Is this a bug in that commit, or a driver bug exposed?

cheers

--=-uEgXX4doiXHynHoq4zge
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkzSiYYACgkQdSjSd0sB4dLicwCfSgzIzTOB4NNB2nAEt9e3ud9L
qOUAn3Xc5pzV0zzPU472z8Nw6lbmIdAF
=dcWX
-----END PGP SIGNATURE-----

--=-uEgXX4doiXHynHoq4zge--

