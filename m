From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 02/11] soc/fsl: Introduce DPAA BMan device management
 driver
Date: Fri, 10 Jul 2015 12:31:43 -0500
Message-ID: <1436549503.2658.157.camel@freescale.com>
References: <1436473322-21247-1-git-send-email-Roy.Pledge@freescale.com>
	 <1436473322-21247-3-git-send-email-Roy.Pledge@freescale.com>
	 <1436517510.20619.123.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roy Pledge <Roy.Pledge@freescale.com>,
	<linuxppc-dev@lists.ozlabs.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0143.outbound.protection.outlook.com ([157.56.111.143]:11793
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751286AbbGJRbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jul 2015 13:31:55 -0400
In-Reply-To: <1436517510.20619.123.camel@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-10 at 10:38 +0200, Paul Bolle wrote:
> On do, 2015-07-09 at 16:21 -0400, Roy Pledge wrote:
> > --- /dev/null
> > +++ b/drivers/soc/fsl/qbman/Kconfig
> > @@ -0,0 +1,33 @@
> > +menuconfig FSL_DPA
> > +   bool "Freescale DPAA support"
> > +   depends on FSL_SOC || COMPILE_TEST
>=20
> Are you sure about COMPILE_TEST?
>=20
> > +   default n
> > +   help
> > +           FSL Data-Path Acceleration Architecture drivers
> > +
> > +           These are not the actual Ethernet driver(s)
> > +
> > +if FSL_DPA
>=20
> [...]
>=20
> > +config FSL_BMAN
> > +   tristate "BMan device management"
> > +   default n
> > +   help
> > +           FSL DPAA BMan driver
> > +
> > +endif # FSL_DPA
>=20
> Because with FSL_BMAN set to 'm' testing things with
>     make -C ../../../.. M=3D$PWD bman.ko   =20
>=20
> will not actually compile on x86_64:
>=20
> make: Entering directory '[...]'
>   CC [M]  [...]/drivers/soc/fsl/qbman/bman.o
> In file included from [...]/drivers/soc/fsl/qbman/bman_priv.h:33:0,
>                  from [...]/drivers/soc/fsl/qbman/bman.c:31:
> [...]/drivers/soc/fsl/qbman/dpaa_sys.h: In function =E2=80=98mfatb=E2=
=80=99:
> [...]/drivers/soc/fsl/qbman/dpaa_sys.h:134:8: error: implicit declara=
tion=20
> of function =E2=80=98mfspr=E2=80=99 [-Werror=3Dimplicit-function-decl=
aration]
>    hi =3D mfspr(SPRN_ATBU);
>         ^
> [...]/drivers/soc/fsl/qbman/dpaa_sys.h:134:14: error: =E2=80=98SPRN_A=
TBU=E2=80=99=20
> undeclared (first use in this function)
>    hi =3D mfspr(SPRN_ATBU);
>               ^
> [...]/drivers/soc/fsl/qbman/dpaa_sys.h:134:14: note: each undeclared=20
> identifier is reported only once for each function it appears in
> [...]/drivers/soc/fsl/qbman/dpaa_sys.h:135:14: error: =E2=80=98SPRN_A=
TBL=E2=80=99=20
> undeclared (first use in this function)
>    lo =3D mfspr(SPRN_ATBL);
>               ^
> [...]/drivers/soc/fsl/qbman/bman.c: In function =E2=80=98__bm_in=E2=80=
=99:
> [...]/drivers/soc/fsl/qbman/bman.c:168:9: error: implicit declaration=
 of=20
> function =E2=80=98in_be32=E2=80=99 [-Werror=3Dimplicit-function-decla=
ration]
>   return in_be32((void *)bm + offset);
>          ^
> [...]/drivers/soc/fsl/qbman/bman.c: In function =E2=80=98__bm_out=E2=80=
=99:
> [...]/drivers/soc/fsl/qbman/bman.c:172:2: error: implicit declaration=
 of=20
> function =E2=80=98out_be32=E2=80=99 [-Werror=3Dimplicit-function-decl=
aration]
>   out_be32((void *)bm + offset, val);

These PPCisms will need to be fixed.  LS1043A is an ARM chip with DPAA =
1.0.

>   ^
> [...]/drivers/soc/fsl/qbman/bman.c: In function =E2=80=98of_fsl_bman_=
probe=E2=80=99:
> [...]/drivers/soc/fsl/qbman/bman.c:463:17: error: =E2=80=98NO_IRQ=E2=80=
=99 undeclared=20
> (first use in this function)
>   if (err_irq =3D=3D NO_IRQ) {

This isn't even a PPCism.  It's just wrong.  Compare to zero instead.

-Scott
