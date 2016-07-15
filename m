From: Scott Wood <oss@buserror.net>
Subject: Re: [v10, 3/7] soc: fsl: add GUTS driver for QorIQ platforms
Date: Fri, 15 Jul 2016 14:12:57 -0500
Message-ID: <1468609977.25630.5.camel@buserror.net>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
	 <1462417950-46796-4-git-send-email-yangbo.lu@nxp.com>
	 <CAP=VYLqsV_M=8CM47k4kzdULCp_y0yP9t8Sq9=jFp6W593QJgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-mmc@vger.kernel.org,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	devicetree@vger.kernel.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-clk@vger.kernel.org,
	linux-i2c@vger.kernel.org, iommu@lists.linux-foundation.org,
	netdev <netdev@vger.kernel.org>, ulf.hansson@linaro.org,
	Mark Rutland <mark.rutland@arm.com>,
	Rob Herring <robh+dt@kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	Jochen Friedrich <jochen@scram.de>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Qiang Zhao <qiang.zhao@nxp.com>,
	Kumar Gala <galak@codeaurora.org>,
	Santosh Shilimkar <ssantosh@kernel.org>, leoyang.li@nxp.com,
	xiaobo.xie@nxp.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Yangbo Lu <yangbo.lu@nxp.com>
Return-path: <linux-clk-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLqsV_M=8CM47k4kzdULCp_y0yP9t8Sq9=jFp6W593QJgw@mail.gmail.com>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-07-15 at 12:43 -0400, Paul Gortmaker wrote:
> On Wed, May 4, 2016 at 11:12 PM, Yangbo Lu <yangbo.lu@nxp.com> wrote:
> >=20
> > The global utilities block controls power management, I/O device
> > enabling, power-onreset(POR) configuration monitoring, alternate
> > function selection for multiplexed signals,and clock control.
> >=20
> > This patch adds GUTS driver to manage and access global utilities
> > block.
> >=20
> > Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
> > Acked-by: Scott Wood <oss@buserror.net>
> > ---
> > Changes for v4:
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Added this patch
> > Changes for v5:
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Modified copyrigh=
t info
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Changed MODULE_LI=
CENSE to GPL
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Changed EXPORT_SY=
MBOL_GPL to EXPORT_SYMBOL
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Made FSL_GUTS use=
r-invisible
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Added a complete =
compatible list for GUTS
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Stored guts info =
in file-scope variable
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Added mfspr() get=
ting SVR
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Redefined GUTS AP=
Is
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Called fsl_guts_i=
nit rather than using platform driver
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Removed useless p=
arentheses
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Removed useless '=
extern' key words
> > Changes for v6:
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Made guts thread =
safe in fsl_guts_init
> > Changes for v7:
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Removed 'ifdef' f=
or function declaration in guts.h
> > Changes for v8:
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Fixes lines longe=
r than 80 characters checkpatch issue
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Added 'Acked-by: =
Scott Wood'
> > Changes for v9:
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- None
> > Changes for v10:
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- None
> > ---
> > =C2=A0drivers/soc/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=
=C2=A0=C2=A02 +-
> > =C2=A0drivers/soc/fsl/Kconfig=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A08 +++
> > =C2=A0drivers/soc/fsl/Makefile |=C2=A0=C2=A0=C2=A01 +
> > =C2=A0drivers/soc/fsl/guts.c=C2=A0=C2=A0=C2=A0| 119
> > ++++++++++++++++++++++++++++++++++++++++++++
> > =C2=A0include/linux/fsl/guts.h | 126 +++++++++++++++++++++++++++++-=
------------
> > -----
> > =C2=A05 files changed, 207 insertions(+), 49 deletions(-)
> > =C2=A0create mode 100644 drivers/soc/fsl/Kconfig
> > =C2=A0create mode 100644 drivers/soc/fsl/guts.c
> >=20
> > diff --git a/drivers/soc/Kconfig b/drivers/soc/Kconfig
> > index cb58ef0..7106463 100644
> > --- a/drivers/soc/Kconfig
> > +++ b/drivers/soc/Kconfig
> > @@ -2,7 +2,7 @@ menu "SOC (System On Chip) specific Drivers"
> >=20
> > =C2=A0source "drivers/soc/bcm/Kconfig"
> > =C2=A0source "drivers/soc/brcmstb/Kconfig"
> > -source "drivers/soc/fsl/qe/Kconfig"
> > +source "drivers/soc/fsl/Kconfig"
> > =C2=A0source "drivers/soc/mediatek/Kconfig"
> > =C2=A0source "drivers/soc/qcom/Kconfig"
> > =C2=A0source "drivers/soc/rockchip/Kconfig"
> > diff --git a/drivers/soc/fsl/Kconfig b/drivers/soc/fsl/Kconfig
> > new file mode 100644
> > index 0000000..b313759
> > --- /dev/null
> > +++ b/drivers/soc/fsl/Kconfig
> > @@ -0,0 +1,8 @@
> > +#
> > +# Freescale SOC drivers
> > +#
> > +
> > +source "drivers/soc/fsl/qe/Kconfig"
> > +
> > +config FSL_GUTS
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0bool
> > diff --git a/drivers/soc/fsl/Makefile b/drivers/soc/fsl/Makefile
> > index 203307f..02afb7f 100644
> > --- a/drivers/soc/fsl/Makefile
> > +++ b/drivers/soc/fsl/Makefile
> > @@ -4,3 +4,4 @@
> >=20
> > =C2=A0obj-$(CONFIG_QUICC_ENGINE)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0+=3D qe/
> > =C2=A0obj-$(CONFIG_CPM)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0+=3D qe/
> > +obj-$(CONFIG_FSL_GUTS)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0+=3D guts.o
> > diff --git a/drivers/soc/fsl/guts.c b/drivers/soc/fsl/guts.c
> > new file mode 100644
> > index 0000000..fa155e6
> > --- /dev/null
> > +++ b/drivers/soc/fsl/guts.c
> > @@ -0,0 +1,119 @@
> > +/*
> > + * Freescale QorIQ Platforms GUTS Driver
> > + *
> > + * Copyright (C) 2016 Freescale Semiconductor, Inc.
> > + *
> > + * This program is free software; you can redistribute it and/or m=
odify
> > + * it under the terms of the GNU General Public License as publish=
ed by
> > + * the Free Software Foundation; either version 2 of the License, =
or
> > + * (at your option) any later version.
> > + */
> > +
> > +#include <linux/io.h>
> > +#include <linux/module.h>
> Seems there was lots of discussion on this.=C2=A0=C2=A0If it does end=
 up being
> resent, it would be nice to get the module.h and other modular stuff
> gone since it is a bool Kconfig.

I plan to resend just the GUTS driver portion and send it through the P=
PC
tree.

I don't see any modular stuff in there besides the linux/module.h inclu=
de.

-Scott


