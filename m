From: Christian Hesse <mail@eworm.de>
Subject: Re: [PATCH v2 1/1] ip-link: in human readable output use dynamic
 precision length
Date: Tue, 4 Nov 2014 22:10:38 +0100
Message-ID: <20141104221038.440fd9d7@leda.localdomain>
References: <20141104114421.6a7f9de5@leda.localdomain>
	<1415098208-17942-1-git-send-email-mail@eworm.de>
	<063D6719AE5E284EB5DD2968C1650D6D1C9E72A7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/sGH+r_pn2c30JGfDT7_VASF"; protocol="application/pgp-signature"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([148.251.109.235]:44152 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbaKDVKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 16:10:51 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9E72A7@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/sGH+r_pn2c30JGfDT7_VASF
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

David Laight <David.Laight@ACULAB.COM> on Tue, 2014/11/04 11:06:
> From: Christian Hesse
> ...
> > ...
> > @@ -343,8 +344,11 @@ static void print_num(FILE *fp, unsigned width,
> > uint64_t count) ++prefix;
> >  	}
> >=20
> > -	snprintf(buf, sizeof(buf), "%.1f%c%s", (double) count / powi,
> > -		 *prefix, use_iec ? "i" : "");
> > +	if ((precision =3D 3 - snprintf(NULL, 0, "%"PRIu64, count / powi))
> > < 0)
>=20
> Don't put assignments in conditionals.

Ok. :D

I do not like this at all... snprintf() would be nice for a catch-all, but =
we
have to take care of negative values. So let's try something different.
I will think about it and send a new patch.

> > +		precision =3D 0;
> > +
> > +	snprintf(buf, sizeof(buf), "%.*f%c%s", precision,
> > +		(double) count / powi, *prefix, use_iec ? "i" : "");
> >=20
> >  	fprintf(fp, "%-*s ", width, buf);
> >  }
>=20
> The above will go wrong in all sorts of horrid ways....
> For instance you are doing a truncating integer divide, but the FP
> value will get rounded for display.
>=20
> It would be safer to use integers throughout.

My implementation used integers, but Stephen changes this to floating point
with his cleanups.

IMHO the rounding is ok. This is for *human* readability. ;)
Whoever wants correct values should not ask ip to print human readable valu=
es
but rely on pure numbers.

> Oh, and a 2Mbit E1 link is actually 2048000 :-)

Sorry? Did not get the point.
--=20
Best regards,
Chris

--Sig_/sGH+r_pn2c30JGfDT7_VASF
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUWUDTAAoJEFTtyRYJvJGDeNMP/i62VxTinzTrqLxiMkAD2CrT
xiHcuCvOUIvw/OW7GMXeoBfDf6ttR5WFevChy9BhSQV4fx86d3ZJOJ9rZlJCSsmr
wbLM636naNYRZ7WQa/vyjYEQBUhdtRPEeiD9RvD9jbTCk9Ci5vOAww8kZ8Vo4ok/
PY5+Y9Is/BpI0uNxxjKKruS6E2oMM7NF/zPnvmTdxyg6ZuN45nG9aTzniaRnjKym
CoT9qw8JYvPg/KvPgb0/O2n7x8pryL6cpZ7GErMUwNErWSBW8DcQB4IWYwY7vCEn
PMCdWDGVcGhGSWbGp647qGSJogEn5zoNuxs7bfGCOQnrezsM1khm5WO06mU/aEdk
762eR72MiLwl+GvwUf45PLDcX+1qdc1cOvo5dMSF7Rj5418licaSvjUQ1aIRxnVn
vVm1lwitsu82wZsU0NUjyzjuIR+rCBVA4AFXFUb1xuZjeExMUgXLqVHb3WxI0CRV
uuYWVjUSHsWXzbJ5fF44ssqZwC4hCiOZM0p8UYcWVhv1FfLhk3UxcFJrx5dCX9cs
4MBNLYJaAmfZxXgAs73Kv4z9UweeFZBAh2agKssMyB+5CCSCcU6NH/ghjQkOCnDg
vpybVZgyHVk8eD0ARPwh9gC3rR4VvJUtZ2scOeXypiMLuZRsw0usDlMwXRir0JJy
EjK8GT/AFYAHKDRFOyTQ
=Vlna
-----END PGP SIGNATURE-----

--Sig_/sGH+r_pn2c30JGfDT7_VASF--
