From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v3 02/12] ethtool.c: don't ignore fread() return
 value
Date: Mon, 07 Mar 2016 15:55:44 +0000
Message-ID: <1457366144.15205.13.camel@decadent.org.uk>
References: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
	 <1457138533-2417-3-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-MnDeurjCV60RLn231MnA"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43626 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752803AbcCGPzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 10:55:51 -0500
In-Reply-To: <1457138533-2417-3-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-MnDeurjCV60RLn231MnA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-04 at 16:42 -0800, David Decotigny wrote:
> From: David Decotigny <decot@googlers.com>
>=20
> This addresses:
> =C2=A0 ethtool.c:1116:8: warning: ignoring return value of =E2=80=98fread=
=E2=80=99, declared with attribute warn_unused_result [-Wunused-result]
>=20
>=20
> Signed-off-by: David Decotigny <decot@googlers.com>
> ---
> =C2=A0ethtool.c | 5 ++++-
> =C2=A01 file changed, 4 insertions(+), 1 deletion(-)
>=20
> diff --git a/ethtool.c b/ethtool.c
> index 92c40b8..8a93dd1 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -1007,6 +1007,7 @@ static int dump_regs(int gregs_dump_raw, int gregs_=
dump_hex,
> =C2=A0	if (gregs_dump_file) {
> =C2=A0		FILE *f =3D fopen(gregs_dump_file, "r");
> =C2=A0		struct stat st;
> +		size_t nread;
> =C2=A0
> =C2=A0		if (!f || fstat(fileno(f), &st) < 0) {
> =C2=A0			fprintf(stderr, "Can't open '%s': %s\n",
> @@ -1016,8 +1017,10 @@ static int dump_regs(int gregs_dump_raw, int gregs=
_dump_hex,
> =C2=A0
> =C2=A0		regs =3D realloc(regs, sizeof(*regs) + st.st_size);
> =C2=A0		regs->len =3D st.st_size;
> -		fread(regs->data, regs->len, 1, f);
> +		nread =3D fread(regs->data, regs->len, 1, f);
> =C2=A0		fclose(f);
> +		if (1 !=3D nread)

This comparison should be written the other way round, no matter what
your personal preference is.

Ben.

> +			return -1;
> =C2=A0	}
> =C2=A0
> =C2=A0	if (!gregs_dump_hex)
--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g
--=-MnDeurjCV60RLn231MnA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW3aSAAAoJEOe/yOyVhhEJRi8P/RLBx9y/paRIbdtxzsHfhndJ
RsFmWxm06zFGq0Ih3AOMomg6pWi8bBZT4phP1MS06kvO1sCDiAy5cwxuI6yeB0y9
sTprjGeGL/Vhlc8keURpVaKLVi2VPdY3jKt51bFmKmR1a5T/BOR+qZhRsp5e3I8K
XK4QmGXqeJdj7HS6P3Bj5+Kfc1OLLUmLdUMOZqk8IDiyK8g47P6XvhIbdVNbtOf4
Zaf33MPkl5iWuD1AuOqSDIbjMuKjWIdOekvFcIXdiFOZAkMSoja65qCKY2OL6yhA
fJAi1DxgOTlV/pVlzDqMlmKysrXVntEZdYn96zxuBz8xb1rPeCKFWOq4DWd82k+Y
WoFrYis+PdlRuwjzIs2W4wQiZMofN4f9k7zSnX5Ime7oqKWuD3DUjl5Q6KyyfCbG
i5IzgSB9+BU0xFuTWVtjpeeFlLhvZP/RK9Vu2Tf8f+Qz2YghsXNJcGLWnbbwLGrS
AfeB304YPx6GVdG4uG7YVyk0wtsLV37GK/77fWSXhANUGDDJccUpaBW4uyDxJEas
V30fv/678LFzi8yWflY2YIwLXTWqcFlahCSpiJBhs7KWMTrc5V/zbcG1Z4Ix/Umx
q3PlLGC7QSPzDum2FKEM5qa44U0cxD6stdpD81KZn9uIzrWJdfP6FQPk/jqDIuCi
wyuIWg2AfDzqwx97pQBu
=O1k8
-----END PGP SIGNATURE-----

--=-MnDeurjCV60RLn231MnA--
