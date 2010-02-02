From: "Liu Yu-B13201" <B13201@freescale.com>
Subject: RE: [PATCH 2/4] mpc8569mds: Add bscr setting for rtbi mode
Date: Tue, 2 Feb 2010 13:57:34 +0800
Message-ID: <0A1FE637C2C7E148B9573BB60CC630E576290E@zch01exm26.fsl.freescale.net>
References: <1263456799-3306-1-git-send-email-yu.liu@freescale.com> <1263456799-3306-2-git-send-email-yu.liu@freescale.com> <fa686aa41002011357pb24d8a6k640ab5ae13f8fbbc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <galak@kernel.crashing.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>
To: "Grant Likely" <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:51288 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128Ab0BBF5y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 00:57:54 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id o125vbfN004576
	for <netdev@vger.kernel.org>; Mon, 1 Feb 2010 22:57:37 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id o1263NGg019121
	for <netdev@vger.kernel.org>; Tue, 2 Feb 2010 00:03:24 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <fa686aa41002011357pb24d8a6k640ab5ae13f8fbbc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks.
As the patchset is accepted.
Will commit another one to fix them.

=20
> -----Original Message-----
> From: glikely@secretlab.ca [mailto:glikely@secretlab.ca] On=20
> Behalf Of Grant Likely
> Sent: Tuesday, February 02, 2010 5:58 AM
> To: Liu Yu-B13201
> Cc: galak@kernel.crashing.org; davem@davemloft.net;=20
> netdev@vger.kernel.org; linuxppc-dev@lists.ozlabs.org
> Subject: Re: [PATCH 2/4] mpc8569mds: Add bscr setting for rtbi mode
>=20
> On Thu, Jan 14, 2010 at 1:13 AM, Liu Yu <yu.liu@freescale.com> wrote:
> > Signed-off-by: Liu Yu <yu.liu@freescale.com>
> > ---
> > =A0arch/powerpc/platforms/85xx/mpc85xx_mds.c | =A0 24=20
> ++++++++++++++++++++++++
> > =A01 files changed, 24 insertions(+), 0 deletions(-)
> >
> > diff --git a/arch/powerpc/platforms/85xx/mpc85xx_mds.c=20
> b/arch/powerpc/platforms/85xx/mpc85xx_mds.c
> > index c5028a2..0872e4a 100644
> > --- a/arch/powerpc/platforms/85xx/mpc85xx_mds.c
> > +++ b/arch/powerpc/platforms/85xx/mpc85xx_mds.c
> > @@ -237,6 +237,8 @@ static void __init mpc85xx_mds_setup_arch(void)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else if (machine_is(mpc8569_mds)) =
{
> > =A0#define BCSR7_UCC12_GETHnRST =A0 (0x1 << 2)
> > =A0#define BCSR8_UEM_MARVELL_RST =A0(0x1 << 1)
> > +#define BCSR_UCC_RGMII =A0 =A0 =A0 =A0 (0x1 << 6)
> > +#define BCSR_UCC_RTBI =A0 =A0 =A0 =A0 =A0(0x1 << 5)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * U-Boot mangles in=
terrupt polarity=20
> for Marvell PHYs,
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * so reset built-in=
 and UEM Marvell=20
> PHYs, this puts
> > @@ -247,6 +249,28 @@ static void __init mpc85xx_mds_setup_arch(void=
)
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0setbits8(&bcsr_regs[=
7],=20
> BCSR7_UCC12_GETHnRST);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0clrbits8(&bcsr_regs[=
8],=20
> BCSR8_UEM_MARVELL_RST);
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (np =3D NULL; (np=
 =3D=20
> of_find_compatible_node(np,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "network",
>=20
> Don't match on the 'type' field.  Replace "network" with NULL and jus=
t
> rely on "ucc_geth" for matching.
>=20
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=20
> "ucc_geth")) !=3D NULL;) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const=
 unsigned int *prop;
>=20
> u32 please.
>=20
> Also, rather than reusing 'prop' for both char* and u32 values, which
> forces you to use ugly casts, use 2 local variables here.
>=20
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int u=
cc_num;
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 prop =
=3D of_get_property(np,=20
> "cell-index", NULL);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p=
rop =3D=3D NULL)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 continue;
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ucc_n=
um =3D *prop - 1;
>=20
> Ugh.  No bounds checking...
>=20
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 prop =
=3D of_get_property(np,=20
> "phy-connection-type", NULL);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p=
rop =3D=3D NULL)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 continue;
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (s=
trcmp("rtbi", (const=20
> char *)prop) =3D=3D 0)
>=20
> (This is the ugly cast I was talking about.)
>=20
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0=20
> clrsetbits_8(&bcsr_regs[7 + ucc_num],
>=20
> ...not having bounds checking could result in badness in this=20
> array index.
>=20
> This patch is dangerous as written.
>=20
> Finally, while using cell-index seems convenient, I think it would be
> better to have a lookup table of the index into the BCSR register
> block from the UCC base address, which also gives you implicit bounds
> checking.
>=20
> g.
>=20
> --=20
> Grant Likely, B.Sc., P.Eng.
> Secret Lab Technologies Ltd.
>=20
>=20
