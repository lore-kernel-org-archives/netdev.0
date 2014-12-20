From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Re:Re: [linux-nics] [PATCH]e100 in linux-3.18.0: some potential
 bugs
Date: Sat, 20 Dec 2014 04:52:51 -0800
Message-ID: <1419079971.2461.96.camel@jtkirshe-mobl.home>
References: <000001d01c28$41c937c0$c55ba740$@163.com>
	 <1419070689.2461.79.camel@jtkirshe-mobl.home>
	 <1e83d62.1197.14a67b6f11a.Coremail.baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-N8gDqwiXYBcIy+3tahV3"
Cc: netdev <netdev@vger.kernel.org>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: =?UTF-8?Q?=E7=99=BD=E5=AE=B6=E9=A9=B9?= <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40827 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752893AbaLTMww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 07:52:52 -0500
In-Reply-To: <1e83d62.1197.14a67b6f11a.Coremail.baijiaju1990@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-N8gDqwiXYBcIy+3tahV3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-12-20 at 20:40 +0800, =E7=99=BD=E5=AE=B6=E9=A9=B9 wrote:
> Thank for the reply!
> =20
> For the first reply:
> I let pci_pool_create fail on purpose to simulate insufficient memory,
> and then run the driver in reality, but the driver crashes.
> =20
> For the second reply:
> I admit you are right, and my code style need to be improved.
>=20

Added in netdev and e1000-devel back onto the CC, since Jia-Ju Bai
removed them in his reply

>=20
> At 2014-12-20 18:18:09,"Jeff Kirsher" <jeffrey.t.kirsher@intel.com> wrote=
:
> >On Sat, 2014-12-20 at 15:40 +0800, Jia-Ju Bai wrote:
> >> I have actually tested e100 driver on the real hardware(Intel 82559
> >> PCI
> >> Ethernet Controller), and find some bugs:
> >> The target file is drivers/net/ethernet/intel/e100.c, which is used to
> >> build
> >> e100.ko.
> >>=20
> >> (1) The function pci_pool_create is called by e100_probe when
> >> initializing
> >> the ethernet card driver. But when pci_pool_create is failed, which
> >> means
> >> that it returns NULL to nic->cbs_pool, the system crash will happen.
> >> Because
> >> pci_pool_alloc (in e100_alloc_cbs in e100_up in e100_open) need to use
> >> nic->cbs_pool to allocate the resource, but it is NULL. I suggest that
> >> a
> >> check can be added in the code to detect whether pci_pool_create
> >> returns
> >> NULL.
> >> (2) In the normal process, netif_napi_add is called in e100_probe, but
> >> netif_napi_del is not called in e100_remove. However, many other
> >> ethernet
> >> card drivers call them in pairs, even in the error handling paths,
> >> such as
> >> r8169 and igb.
> >>=20
> >> Meanwhile, I also write the patch to fix the bugs. I have run the
> >> patch on
> >> the hardware, it can work normally and fix the above bugs.
> >
> >Did you actually experience an issue?  Or is this a theoretical issue
> >that was never actually seen?
> >
> >>=20
> >> diff --git a/drivers/net/ethernet/intel/e100.c
> >> b/drivers/net/ethernet/intel/e100.c
> >> index 781065e..2631d3f 100644
> >> --- a/drivers/net/ethernet/intel/e100.c
> >> +++ b/drivers/net/ethernet/intel/e100.c
> >> @@ -2969,6 +2969,11 @@ static int e100_probe(struct pci_dev *pdev,
> >> const
> >> struct pci_device_id *ent)
> >>                            nic->params.cbs.max * sizeof(struct cb),
> >>                            sizeof(u32),
> >>                            0);
> >> +       if(!(nic->cbs_pool))
> >> +       {
> >> +               err =3D -ENOMEM;
> >> +               goto err_out_pool;
> >> +       }
> >>         netif_info(nic, probe, nic->netdev,
> >
> >Minor nit-pick but your open bracket needs to be on the same line as the
> >if statement AND you need a space between the 'if' and ().  So the above
> >code should look like:
> >	if (!nic->cbs_pool) {
> >		err =3D -ENOMEM;
> >		goto err_out_pool;
> >	}
>=20
>=20



--=-N8gDqwiXYBcIy+3tahV3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUlXEjAAoJEOVv75VaS+3Ot5wQAJ1GOSSInU0SJL2B2UskqL/Y
0iL6ThH0/FWLrun2Tm++D1LGrusZo862ee6FsL67WnzfVh/wQg62TjI+FA5hv7ft
1uKCf0uVi2Nzuu8/szt4LCcWFV+OoKLdqmCaK8qighVWPhagep5Q97AGQgRRIia/
zbqYYXBnFZAjU2KfIEEoOLUIeTZFTt6rLNzn/VgSN5NT4zcTTQ9ADVr4FTRJtwLN
S+9cjmMZ4jFiInv7z+OcPNtx+J1Oyo7GpE8jfr9DbY95ebOpH4JTZDKKtaiXvcqv
cOu3zhGlBJe60r+zhlJNK7vZuPwKDFD5D3Q6oYs0njKup9jPQYdnbi6iAwgrPLHS
fFoEuAObMjwo8S2Qif0mPQF9pj7LoSSoNpN8Sm46ICy96n2Vwoe6arWeBRHabIdM
KOUgMCeug81T14y+YycIU828L91rs1rPFUbgxI+nqB1Sr9ww5hy2InmmyiDlqmzu
7x36X0ybOnGFmcgutpysqDfwxVhIpZiaA+3zzCkjmc4wPe+BCtfApvhxj8e9NnrB
KsUzuwAFfTrSDZTLgoKhF5YolGFnWI/GxRGvO5YsMi/Jw2b2FfefcOAlDYAHPCpK
fXhOPedgxMZM8nu8sfr5lB7ryqGikJC+5AlMiLYTmLLzZe+tzuJz47/lNb0ekVFv
AQiUDHItKEHN0Lt8SD11
=J3/f
-----END PGP SIGNATURE-----

--=-N8gDqwiXYBcIy+3tahV3--
