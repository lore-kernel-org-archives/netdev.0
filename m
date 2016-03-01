From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] ethtool.h: define DIV_ROUND_UP for userland
Date: Tue, 01 Mar 2016 15:29:01 +0000
Message-ID: <1456846141.3098.155.camel@decadent.org.uk>
References: <1456845641-6985-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-8VlglfkVKKL0Ei5Q+HWu"
Cc: netdev@vger.kernel.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Kan Liang <kan.liang@intel.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45212 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753981AbcCAP3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 10:29:18 -0500
In-Reply-To: <1456845641-6985-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-8VlglfkVKKL0Ei5Q+HWu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-03-01 at 16:20 +0100, Nicolas Dichtel wrote:
> DIV_ROUND_UP and is defined in linux/kernel.h only for the kernel.
[...]

But what happens when another UAPI header wants to use DIV_ROUND_UP()?
=C2=A0Do we duplicate the definition there as well?

It seems cleaner to do something like:

--- a/include/uapi/linux/kernel.h
+++ b/include/uapi/linux/kernel.h
+#define __KERNEL_DIV_ROUND_UP(n, d) (((n) + (d) - 1) / (d))

--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
-#define DIV_ROUND_UP(n, d) (((n) + (d) - 1) / (d))
+#define DIV_ROUND_UP __KERNEL_DIV_ROUND_UP

and then in include/uapi/linux/ethtool.h, replace DIV_ROUND_UP with
__KERNEL_DIV_ROUND_UP throughout.

Ben.

--=20
Ben Hutchings
If God had intended Man to program,
we'd have been born with serial I/O ports.
--=-8VlglfkVKKL0Ei5Q+HWu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVtW1Pee/yOyVhhEJAQqHRQ//TrT/bHUzwGdb3g1PMiP77VE6GDJfjnKB
PgfP++y4UO0nV+kwHyeGB4w6pwVdx2VeLOm07byHSA0QB+lukcAWXOUz55aJuZci
1a8gfuVE98o+dC9ko4mUtq7OHa3klKhrSvqygYsZnGO5BfDZRW+bJ/5YQvSddj3C
LxtHxr4lXBcO9Wg8g4q/qm/bIs/pncgAS8QF1sQXXxuFpfYVv+yD7xqIjeQVOArq
jL3ms0FjE3xA1+cz9DLGlmsqScL3jsyM8yOhNTomiE2qzWwqm6uLloG47xmhH03v
QxHRkR/DX5z7lu/OTedAwUQbY59j0CgWNM0LqYxKsDeIr3yh61gu98JolIzCvwHo
LVxmhTYJKf2OQCw+H/9lJ+9HKJ6spoE+Ov8W/5hHQzdnWEu4hdvfbfp3fyUCCXQ4
3cwx10sbOBno2di4Beddz3oVDraN+qizHP0WCRXp07HTEV78t5q1h2w4U2D7bixc
j3kFWqnMqCinRiZzzQlOGpJxEC9lSZt+3ZYGhJuo8QR48uVr4iR36ysVxUV8uAPm
NvFPIgEj2fLr9VC+2X0+ixgfZ1Iux6E39yFwSukHQ0kWwv/yx+7w7QuKyazn2jBz
6+DRbxObB1zk+0hG/bFkdEey023OUafaEfg8Met11oT6Q84mmryUXfR2cjDEz9Xb
HekEIyLXTdg=
=TiSy
-----END PGP SIGNATURE-----

--=-8VlglfkVKKL0Ei5Q+HWu--
