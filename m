From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 02/11] soc/fsl: Introduce DPAA BMan device management
 driver
Date: Fri, 10 Jul 2015 10:38:30 +0200
Message-ID: <1436517510.20619.123.camel@tiscali.nl>
References: <1436473322-21247-1-git-send-email-Roy.Pledge@freescale.com>
	 <1436473322-21247-3-git-send-email-Roy.Pledge@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@lists.ozlabs.org, scottwood@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Roy Pledge <Roy.Pledge@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb3-smtp-cloud6.xs4all.net ([194.109.24.31]:53413 "EHLO
	lb3-smtp-cloud6.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751838AbbGJIie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 04:38:34 -0400
In-Reply-To: <1436473322-21247-3-git-send-email-Roy.Pledge@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On do, 2015-07-09 at 16:21 -0400, Roy Pledge wrote:
> --- /dev/null
> +++ b/drivers/soc/fsl/qbman/Kconfig
> @@ -0,0 +1,33 @@
> +menuconfig FSL_DPA
> +	bool "Freescale DPAA support"
> +	depends on FSL_SOC || COMPILE_TEST

Are you sure about COMPILE_TEST?

> +	default n
> +	help
> +		FSL Data-Path Acceleration Architecture drivers
> +
> +		These are not the actual Ethernet driver(s)
> +
> +if FSL_DPA

[...]

> +config FSL_BMAN
> +	tristate "BMan device management"
> +	default n
> +	help
> +		FSL DPAA BMan driver
> +
> +endif # FSL_DPA

Because with FSL_BMAN set to 'm' testing things with
    make -C ../../../.. M=3D$PWD bman.ko   =20

will not actually compile on x86_64:

make: Entering directory '[...]'
  CC [M]  [...]/drivers/soc/fsl/qbman/bman.o
In file included from [...]/drivers/soc/fsl/qbman/bman_priv.h:33:0,
                 from [...]/drivers/soc/fsl/qbman/bman.c:31:
[...]/drivers/soc/fsl/qbman/dpaa_sys.h: In function =E2=80=98mfatb=E2=80=
=99:
[...]/drivers/soc/fsl/qbman/dpaa_sys.h:134:8: error: implicit declarati=
on of function =E2=80=98mfspr=E2=80=99 [-Werror=3Dimplicit-function-dec=
laration]
   hi =3D mfspr(SPRN_ATBU);
        ^
[...]/drivers/soc/fsl/qbman/dpaa_sys.h:134:14: error: =E2=80=98SPRN_ATB=
U=E2=80=99 undeclared (first use in this function)
   hi =3D mfspr(SPRN_ATBU);
              ^
[...]/drivers/soc/fsl/qbman/dpaa_sys.h:134:14: note: each undeclared id=
entifier is reported only once for each function it appears in
[...]/drivers/soc/fsl/qbman/dpaa_sys.h:135:14: error: =E2=80=98SPRN_ATB=
L=E2=80=99 undeclared (first use in this function)
   lo =3D mfspr(SPRN_ATBL);
              ^
[...]/drivers/soc/fsl/qbman/bman.c: In function =E2=80=98__bm_in=E2=80=99=
:
[...]/drivers/soc/fsl/qbman/bman.c:168:9: error: implicit declaration o=
f function =E2=80=98in_be32=E2=80=99 [-Werror=3Dimplicit-function-decla=
ration]
  return in_be32((void *)bm + offset);
         ^
[...]/drivers/soc/fsl/qbman/bman.c: In function =E2=80=98__bm_out=E2=80=
=99:
[...]/drivers/soc/fsl/qbman/bman.c:172:2: error: implicit declaration o=
f function =E2=80=98out_be32=E2=80=99 [-Werror=3Dimplicit-function-decl=
aration]
  out_be32((void *)bm + offset, val);
  ^
[...]/drivers/soc/fsl/qbman/bman.c: In function =E2=80=98of_fsl_bman_pr=
obe=E2=80=99:
[...]/drivers/soc/fsl/qbman/bman.c:463:17: error: =E2=80=98NO_IRQ=E2=80=
=99 undeclared (first use in this function)
  if (err_irq =3D=3D NO_IRQ) {
                 ^
cc1: some warnings being treated as errors
scripts/Makefile.build:264: recipe for target '[...]/drivers/soc/fsl/qb=
man/bman.o' failed
make[1]: *** [[...]/drivers/soc/fsl/qbman/bman.o] Error 1
Makefile:1568: recipe for target 'bman.ko' failed
make: *** [bman.ko] Error 2
make: Leaving directory '[...]'

Thanks,


Paul Bolle
