From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure
Date: Wed, 27 Aug 2008 10:06:56 +1000
Message-ID: <20080827100656.0f87e6b2.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__27_Aug_2008_10_06_56_+1000_yGzy/8/2JulXPKsH"
Cc: linux-next@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:44602 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068AbYH0AHH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 20:07:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__27_Aug_2008_10_06_56_+1000_yGzy/8/2JulXPKsH
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

next-20080826 build (powerpc mpc885_ads_defconfig) failed like this:

net/core/dev.c:1000: error: redefinition of 'dev_load'
include/linux/netdevice.h:1645: error: previous definition of 'dev_load' wa=
s here

This also failed for several other builds where CONFIG_MODULES is off.

Introduced by commit 4cb9da6ecc2b0e25056b45981239475f8509d59d ("remove
CONFIG_KMOD from net") which added a !CONFIG_MODULES (static inline)
version of dev_load() to include/linux/netdevice.h but the copy in
net/core/dev.c is not protected by CONFIG_MODULES.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__27_Aug_2008_10_06_56_+1000_yGzy/8/2JulXPKsH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAki0mqAACgkQjjKRsyhoI8z01gCfSlh05qSe1ZgV8t+4RXKLDho2
1/8AniFREXaXVt4vYXKlPDZMdCZt/F2l
=vlqj
-----END PGP SIGNATURE-----

--Signature=_Wed__27_Aug_2008_10_06_56_+1000_yGzy/8/2JulXPKsH--
