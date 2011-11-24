From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] isdn: make sure strings are null terminated
Date: Thu, 24 Nov 2011 14:34:56 +0300
Message-ID: <20111124113456.GI3258@mwanda>
References: <20111123064204.GA6871@elgon.mountain>
 <4ECCAE14.3070008@bfs.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GBuTPvBEOL0MYPgd"
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:46770 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015Ab1KXLey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 06:34:54 -0500
Content-Disposition: inline
In-Reply-To: <4ECCAE14.3070008@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--GBuTPvBEOL0MYPgd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 23, 2011 at 09:25:56AM +0100, walter harms wrote:
>=20
>=20
> Am 23.11.2011 07:42, schrieb Dan Carpenter:
> > These strings come from the user.  We strcpy() them inside
> > cf_command() so we should check that they are NULL terminated and
> > return an error if not.
> >=20
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> >=20
> > diff --git a/drivers/isdn/divert/divert_procfs.c b/drivers/isdn/divert/=
divert_procfs.c
> > index 33ec9e4..0c16687 100644
> > --- a/drivers/isdn/divert/divert_procfs.c
> > +++ b/drivers/isdn/divert/divert_procfs.c
> > @@ -242,6 +242,10 @@ static int isdn_divert_ioctl_unlocked(struct file =
*file, uint cmd, ulong arg)
> >  		case IIOCDOCFINT:
> >  			if (!divert_if.drv_to_name(dioctl.cf_ctrl.drvid))
> >  				return (-EINVAL);	/* invalid driver */
> > +			if (strlen(dioctl.cf_ctrl.msn) >=3D sizeof(dioctl.cf_ctrl.msn))
> > +				return -EINVAL;
> > +			if (strlen(dioctl.cf_ctrl.fwd_nr) >=3D sizeof(dioctl.cf_ctrl.fwd_nr=
))
> > +				return -EINVAL;
>=20
> forcing the last field to be zero seems more easy.
> dioctl.cf_ctrl.fwd_nr[sizeof(dioctl.cf_ctrl.fwd_nr))-1]=3D0;
>=20

That's a valid option to use, but I'd prefer to return an error code
here because that's what we do on the line before.  Passing a too
long string is clearly invalid.

regards,
dan carpenter


--GBuTPvBEOL0MYPgd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJOzivgAAoJEOnZkXI/YHqRJxIQAK/ueDDtlnugSjTRLQpRw9f1
Rh8QC+gyeE4GedQPqTLCHd85uqvkg9p+eUyRBnzQt7wyvUBXbiFwwY9ODlvlrLgG
hig8cU9T0CUwjzfWQ4S/wCfTmirMBLpFuLLUjNoWob3qkcWVrazRM7giDjGuO2+C
PX0HtMlLPG6i2ZcwAI/uAHGQKmB4IpnJ0cBx2bUL4dCs2HOeeoSOdL6/XcPhWkVL
aF/ypISqxefJH+NPCJoRFeb7iQGuhku5GVG2bqiyGlgIwFMLvtWnLxfRf8bXHM7b
MNkF9EiXVXZ6N7I3L/zIvlSqOuXS/piZ4G+dslKA69R0cQMl5G/wWgDDfT9Coj4n
1KdkahOAtR8QtO1KlRsv58IwFfrey31T2IL3uY/tL0cjX8zJqeN+/hWWK+vk6Yzw
MnB9CQnt5OxDaCWh5R2Ptbpvy3dOcR7krfyIZBGrBdt0i2rUoJZJNaoS6sUQxuFL
oOeGDLJGWSHB4bxE/0kWH1Kf0iXXmPSvVDoyUNTZf3Sjpa1ROHPnt8koR+Ikuy0e
M5LA2Qj9mxagDeQIjg9HCxjJmwrW+JGkgdVUz92W2Kts2kdJ6891kxJ1B5u//O0l
Vp4ZjOGRvgNZiSgLUxv9TyZ3BXOy6RGaHehGCOfGbP61TLyrkcHwLCEXgBsVax+x
1wsp3A1UNrfmBcEaz3/L
=ItrF
-----END PGP SIGNATURE-----

--GBuTPvBEOL0MYPgd--
