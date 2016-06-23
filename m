From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] mellanox: mlx5: Use logging functions to reduce text
 ~10k/5%
Date: Thu, 23 Jun 2016 10:12:10 +0300
Message-ID: <20160623071210.GA23995@leon.nu>
References: <1466619839.13093.4.camel@perches.com>
 <20160623052701.GB30933@leon.nu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jRHKVT23PllUwdXP"
Cc: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160623052701.GB30933-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--jRHKVT23PllUwdXP
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 23, 2016 at 08:27:01AM +0300, Leon Romanovsky wrote:
> On Wed, Jun 22, 2016 at 11:23:59AM -0700, Joe Perches wrote:
> > The logging macros create a bit of duplicated code/text.
> >=20
> > Use specialized functions to reduce the duplication.
> >=20
> > (defconfig/x86-64)
> > $ size drivers/net/ethernet/mellanox/mlx5/core/built-in.o*
> > =C2=A0=C2=A0=C2=A0text	=C2=A0=C2=A0=C2=A0data	=C2=A0=C2=A0=C2=A0=C2=A0b=
ss	=C2=A0=C2=A0=C2=A0=C2=A0dec	=C2=A0=C2=A0=C2=A0=C2=A0hex	filename
> > =C2=A0178634	=C2=A0=C2=A0=C2=A02059	=C2=A0=C2=A0=C2=A0=C2=A0=C2=A016	=
=C2=A0180709	=C2=A0=C2=A02c1e5	drivers/net/ethernet/mellanox/mlx5/core/buil=
t-in.o.new
> > =C2=A0188679	=C2=A0=C2=A0=C2=A02059	=C2=A0=C2=A0=C2=A0=C2=A0=C2=A016	=
=C2=A0190754	=C2=A0=C2=A02e922	drivers/net/ethernet/mellanox/mlx5/core/buil=
t-in.o.old
> >=20
> > The output changes now do not include line #,
> > but do include the function offset.
> >=20
> > Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
>=20
> As far as I see all these functions are used in error paths, so no
> implication on performance is expected.
>=20
> And I'm fine with function offsets.
>=20
> Saeed,
> What do you think?
>=20
> Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

I continued to play with this patch and it doesn't pass checkpatch.
It looks like corrupted file.

=E2=9E=9C  linux-rdma git:(master) ./scripts/checkpatch.pl
~/Downloads/mellanox-mlx5-Use-logging-functions-to-reduce-text-10k-5.patch
WARNING: Possible unwrapped commit description (prefer a maximum 75 chars p=
er line)
#21:=20
=C2=A0178634 =C2=A0=C2=A0=C2=A02059 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A016 =C2=A0=
180709 =C2=A0=C2=A02c1e5
drivers/net/ethernet/mellanox/mlx5/core/built-in.o.new

ERROR: patch seems to be corrupt (line wrapped?)
#46: FILE: drivers/net/ethernet/mellanox/mlx5/core/main.c:1556:

CHECK: Alignment should match open parenthesis
#78: FILE: drivers/net/ethernet/mellanox/mlx5/core/main.c:1586:
+       dev_warn(&dev->pdev->dev, "%s:%pS:(pid %d): %pV",
+               =C2=A0dev->priv.name, __builtin_return_address(0), current-=
>pid,

ERROR: space required before that '&' (ctx:VxV)
#79: FILE: drivers/net/ethernet/mellanox/mlx5/core/main.c:1587:
+               =C2=A0&vaf);
                  ^
total: 2 errors, 1 warnings, 1 checks, 58 lines  checked

--jRHKVT23PllUwdXP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXa4vKAAoJEORje4g2clinSkoP/2Y+3JlC32z5UczfyknEMt4K
nHa0/RzSlaM0dOms8ujawisj/FAtFSTyd4hWLz4/Ogd+IM6YJcjrSXHVGoqgPqW5
oSBtvO2WMePHG9oI2LoY9+C1Pv9d5t5EEU0vhQgpzihWeLDWSxL1pjY3eI1Ny03L
jcYzbG39D91r5vK7u+sksb9QclqQizBtsMVskMqaVLOv70V//uGQ2uwx53pb7fRU
P7EVGM2M3gqAr0N1aNn0f1FDd8kaCvwFdPbVPI/wGaEwkjVK6CoZdHKRwskx3gBk
JmuhfBk+LhKN2tcpNhj9g7kPuY9rfxqvBN4etxPATyzTiV0s8qM0GZXSRU92sjsr
Q7NtlxxmBNun0dGiqczQHPhtk1GNKtpx8ObPNU9fvQf8QC1HgxGttpyxkE0MF+kw
j4IA3ekGcDKGNIgp4u5SLhh5xdNRTSmD2Iu4vBFJSqUjYmV6g+9EBROfBefoPOg5
yqGofrgaNWyR/zWWyybneha+DCi5YCnNIRN8SQuVy7sx4u+5vVa+NJ9tJ2/e4FHU
leXNcoVrA9DcqGVBhu+Gld/T98dSLQpVCqDyhUEk2ttCneBb7UIwjKDhECFsCzeH
7VGFCg8wBcP6jNz2Y524KW9gde4dt74wGaR/z6/00+DIPOYkU2T57ZmLgbAs9Ugf
VRgzFF3YG8H/pxeHinV5
=LXfB
-----END PGP SIGNATURE-----

--jRHKVT23PllUwdXP--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
