From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Potential bugs found in ne2k-pci+8390
Date: Sun, 23 Nov 2014 03:21:15 +0000
Message-ID: <1416712875.7215.36.camel@decadent.org.uk>
References: <000001d00607$90e5ee70$b2b1cb50$@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1iZph1Y85IZVevGblsP1"
Cc: netdev@vger.kernel.org
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45442 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751891AbaKWDVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 22:21:35 -0500
In-Reply-To: <000001d00607$90e5ee70$b2b1cb50$@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1iZph1Y85IZVevGblsP1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-11-22 at 11:51 +0800, Jia-Ju Bai wrote:
> Dear Sir,
> I'm very sorry to trouble you.=20
> Recently I test 15 linux device drivers and find some potential bugs both=
 in
> Linux 3.8.6 and Linux 3.17.2.=20
>=20
> The target file is drivers/net/ethernet/8390/ne2k-pci.c, which is used to
> build ne2k-pci.ko. I hope you can help me check my findings:
> [1] The function request_region is called by ne2k_pci_init_one when
> initializing the ethernet card driver. But when request_region is failed,
> which means that it returns the error value, ne2k_pci_init_one returns
> immediately to halt the process. However, because pci_enable_device has b=
een
> called before request_region in ne2k_pci_init_one, pci_disable_device sho=
uld
> be called before exiting. When the driver works normally, pci_enable_devi=
ce
> and pci_disable_device are called in pairs in ne2k_pci_init_one and
> ne2k_pci_remove_one. Moreover, other ethernet card drivers call
> pci_enable_device and pci_disable_device in pairs in error handling paths=
,
> such as r8169 and sky2.
> [2] The similar problem to [1] occurs when alloc_ei_netdev is failed in
> ne2k_pci_init_one.
> [3] The similar problem to [1] occurs when register_netdev is failed in
> ne2k_pci_init_one.
>=20
> Could you help me check these findings? Thank you very much, and I'm look=
ing
> forward to your reply.

I agree this is a real bug (or bugs).  You should send a patch to fix
this - see Documentation/SubmittingPatches.

Ben.

--=20
Ben Hutchings
Never put off till tomorrow what you can avoid all together.

--=-1iZph1Y85IZVevGblsP1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHFStee/yOyVhhEJAQqU4A/+IboKHe2L+Kxl4UMf+tqp9XYK742Zo99f
XWeX0cE24yt3SyftLuc6dCD/ySwUkt2J4sJhQfB01kn2kuOckc0TbjSmVxahY2Nx
CGi/Suuzu41cKwwwXS/8KZV58g9Qo5tp+aYE79pvfE0h+WL+mkw1kZdbqpfjw+f5
h0gF073qUIGcw0XBhKYsF0nOf/iPya+QbEHHNTys3QXDpRsOrZ+t+BW2B+3gV/jq
oTDfwzK5QJkeyiM0CZY0NAWyhMYOJ7T/BM6wl+JcIOBI2+mXwFVzFvVlJhDiCmgK
rVnLapFie+tlNkAgqLpydu1Ug+LWiqJscChQiIKw27H3v2nWtCLyl0SiX6QpV0YY
zeciihj4sYbQCisQ5D8xGctkGnqoe8il+g/iQdQ1Ic6KKzR2SdslsHh4FO1GPxkH
7m03nMMMTNc6Q8sttmu72ymka8O2/00s3z0SwkHIlgGGq8saskTH/U8qN/w0B6RI
mS/HOeWNOj7TNolY2GIS/KJo22WKD9kmdS09ebJMqGm5ia+dJj1RhfRUS11Qui/X
YqcELItWaAOL7jIekAq4cCXoQXrjhin4F4ststk/syxwp1OhX5s3C/pb2mE6pBom
VlOPr2rA/n0cp8c/B1gZhWeI5KneatoU0Q91i2ufg8+rE1AYOljus/VMpicQ5Glr
6OtWSq20o8A=
=1b4P
-----END PGP SIGNATURE-----

--=-1iZph1Y85IZVevGblsP1--
