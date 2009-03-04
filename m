From: Sascha Hlusiak <mail@saschahlusiak.de>
Subject: Re: [PATCH] Assign linklocal addresses to isatap from link dev
Date: Wed, 4 Mar 2009 18:49:41 +0100
Message-ID: <200903041849.48474.mail@saschahlusiak.de>
References: <200903010134.54405.mail@saschahlusiak.de> <20090304.032835.183524465.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3081262.gppaD4HRfF";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:59010 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415AbZCDRt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 12:49:26 -0500
In-Reply-To: <20090304.032835.183524465.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart3081262.gppaD4HRfF
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

> > That way stateless autoconf works with isatap tunnels and without
> > knowledge of the local v4 address.
>
> Real autoconf is not performed, but rather you must configure your
> system with a PRL (potential routers list) and these routers are
> probed periodically in order to keep track of which of them are still
> functioning and also to perform a sort-of unicast-only autoconf.
Well, since ISATAP is just a SIT, it still needs a link local address for=20
autoconf and it needs to have it's v4 Address embedded in the lowest 32 bit=
 of=20
the linklocal address. It will then do normal autoconf with the potential=20
router by sending a proper router solicitation messages, either directed or=
=20
multicast.

I see that the current implementation disables sending of RS when on ISATAP=
,=20
which is not correct because RS are needed to do the autoconf.

At least that's the way the implementation in MS Windows works.

> I am pretty sure that the person who added the ISATAP code created the
> current behavior intentionally.
Well, the current implementation does not cover clients at all, because=20
the ip command refuses to create tunnels without the remote parameter, whic=
h=20
is neccessary because it's the potential router.

It then does not derive the linklocal address correctly, making it impossib=
le=20
to do autoconf with the server. Using SIT does work as such as you still ne=
ed=20
to add the correct ISATAP linklocal address to the interface.=20

I think ISATAP Client support in Linux could be more automated.


=2D Sascha

--nextPart3081262.gppaD4HRfF
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.10 (GNU/Linux)

iEYEABECAAYFAkmuvzwACgkQOyDtNneHFrMoOwCeJhqUs26tECjjHjUYxjGYi2kq
m8wAoJAV4Awxb3ncRHCR01Y/iSP0uf1y
=7D00
-----END PGP SIGNATURE-----

--nextPart3081262.gppaD4HRfF--
