From: Scott Wood <oss@buserror.net>
Subject: Re: [v16, 0/7] Fix eSDHC host version register bug
Date: Wed, 09 Nov 2016 23:17:30 -0600
Message-ID: <1478755050.21746.8.camel@buserror.net>
References: <1478661252-42439-1-git-send-email-yangbo.lu@nxp.com>
         <CAPDyKFrcAN_pqgtGaUanfB2zh97zGcL23m5VDtJ3g==NJeRrfA@mail.gmail.com>
         <1478750114.21746.4.camel@buserror.net>
          <DB6PR0401MB25369DEFDDDED2A96851259EF8B80@DB6PR0401MB2536.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-mmc <linux-mmc@vger.kernel.org>,
        Arnd Bergmann <arnd@arndb.de>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-clk <linux-clk@vger.kernel.org>,
        "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Rob Herring <robh+dt@kernel.org>,
        Russell King <linux@arm.linux.org.uk>,
        Jochen Friedrich <jochen@scram.de>,
        Joerg Roedel <joro@8bytes.org>,
        Claudiu Manoil <claudiu.manoil@freescale.co
To: "Y.B. Lu" <yangbo.lu@nxp.com>, Ulf Hansson <ulf.hansson@linaro.org>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <DB6PR0401MB25369DEFDDDED2A96851259EF8B80@DB6PR0401MB2536.eurprd04.prod.outlook.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-11-10 at 04:11 +0000, Y.B. Lu wrote:
> > 
> > -----Original Message-----
> > From: Y.B. Lu
> > Sent: Thursday, November 10, 2016 12:06 PM
> > To: 'Scott Wood'; Ulf Hansson
> > Cc: linux-mmc; Arnd Bergmann; linuxppc-dev@lists.ozlabs.org;
> > devicetree@vger.kernel.org; linux-arm-kernel@lists.infradead.org; linux-
> > kernel@vger.kernel.org; linux-clk; iommu@lists.linux-foundation.org;
> > netdev@vger.kernel.org; Greg Kroah-Hartman; Mark Rutland; Rob Herring;
> > Russell King; Jochen Friedrich; Joerg Roedel; Claudiu Manoil; Bhupesh
> > Sharma; Qiang Zhao; Kumar Gala; Leo Li; X.B. Xie; M.H. Lian
> > Subject: RE: [v16, 0/7] Fix eSDHC host version register bug
> > 
> > > 
> > > -----Original Message-----
> > > From: linux-mmc-owner@vger.kernel.org [mailto:linux-mmc-
> > > owner@vger.kernel.org] On Behalf Of Scott Wood
> > > Sent: Thursday, November 10, 2016 11:55 AM
> > > To: Ulf Hansson; Y.B. Lu
> > > Cc: linux-mmc; Arnd Bergmann; linuxppc-dev@lists.ozlabs.org;
> > > devicetree@vger.kernel.org; linux-arm-kernel@lists.infradead.org;
> > > linux- kernel@vger.kernel.org; linux-clk;
> > > iommu@lists.linux-foundation.org; netdev@vger.kernel.org; Greg
> > > Kroah-Hartman; Mark Rutland; Rob Herring; Russell King; Jochen
> > > Friedrich; Joerg Roedel; Claudiu Manoil; Bhupesh Sharma; Qiang Zhao;
> > > Kumar Gala; Leo Li; X.B. Xie; M.H. Lian
> > > Subject: Re: [v16, 0/7] Fix eSDHC host version register bug
> > > 
> > > On Wed, 2016-11-09 at 19:27 +0100, Ulf Hansson wrote:
> > > > 
> > > > - i2c-list
> > > > 
> > > > On 9 November 2016 at 04:14, Yangbo Lu <yangbo.lu@nxp.com> wrote:
> > > > > 
> > > > > 
> > > > > This patchset is used to fix a host version register bug in the
> > > > > T4240-
> > > > > R1.0-R2.0
> > > > > eSDHC controller. To match the SoC version and revision, 15
> > > > > previous version patchsets had tried many methods but all of them
> > > > > were rejected by reviewers.
> > > > > Such as
> > > > >         - dts compatible method
> > > > >         - syscon method
> > > > >         - ifdef PPC method
> > > > >         - GUTS driver getting SVR method Anrd suggested a
> > > > > soc_device_match method in v10, and this is the only available
> > > > > method left now. This v11 patchset introduces the soc_device_match
> > > > > interface in soc driver.
> > > > > 
> > > > > The first four patches of Yangbo are to add the GUTS driver. This
> > > > > is used to register a soc device which contain soc version and
> > > > > revision information.
> > > > > The other three patches introduce the soc_device_match method in
> > > > > soc driver and apply it on esdhc driver to fix this bug.
> > > > > 
> > > > > ---
> > > > > Changes for v15:
> > > > >         - Dropped patch 'dt: bindings: update Freescale DCFG
> > > compatible'
> > > > 
> > > > > 
> > > > >           since the work had been done by below patch on
> > > > > ShawnGuo's linux tree.
> > > > >           'dt-bindings: fsl: add LS1043A/LS1046A/LS2080A
> > > > > compatible for SCFG
> > > > >            and DCFG'
> > > > >         - Fixed error code issue in guts driver Changes for v16:
> > > > >         - Dropped patch 'powerpc/fsl: move mpc85xx.h to
> > > include/linux/fsl'
> > > > 
> > > > > 
> > > > >         - Added a bug-fix patch from Geert
> > > > > ---
> > > > > 
> > > > > Arnd Bergmann (1):
> > > > >   base: soc: introduce soc_device_match() interface
> > > > > 
> > > > > Geert Uytterhoeven (1):
> > > > >   base: soc: Check for NULL SoC device attributes
> > > > > 
> > > > > Yangbo Lu (5):
> > > > >   ARM64: dts: ls2080a: add device configuration node
> > > > >   dt: bindings: move guts devicetree doc out of powerpc directory
> > > > >   soc: fsl: add GUTS driver for QorIQ platforms
> > > > >   MAINTAINERS: add entry for Freescale SoC drivers
> > > > >   mmc: sdhci-of-esdhc: fix host version for T4240-R1.0-R2.0
> > > > > 
> > > > >  .../bindings/{powerpc => soc}/fsl/guts.txt         |   3 +
> > > > >  MAINTAINERS                                        |  11 +-
> > > > >  arch/arm64/boot/dts/freescale/fsl-ls2080a.dtsi     |   6 +
> > > > >  drivers/base/Kconfig                               |   1 +
> > > > >  drivers/base/soc.c                                 |  70 ++++++
> > > > >  drivers/mmc/host/Kconfig                           |   1 +
> > > > >  drivers/mmc/host/sdhci-of-esdhc.c                  |  20 ++
> > > > >  drivers/soc/Kconfig                                |   3 +-
> > > > >  drivers/soc/fsl/Kconfig                            |  18 ++
> > > > >  drivers/soc/fsl/Makefile                           |   1 +
> > > > >  drivers/soc/fsl/guts.c                             | 236
> > > > > +++++++++++++++++++++
> > > > >  include/linux/fsl/guts.h                           | 125
> > > > > ++++++-----
> > > > >  include/linux/sys_soc.h                            |   3 +
> > > > >  13 files changed, 447 insertions(+), 51 deletions(-)
> > > > >  rename Documentation/devicetree/bindings/{powerpc =>
> > > > > soc}/fsl/guts.txt
> > > > > (91%)
> > > > >  create mode 100644 drivers/soc/fsl/Kconfig
> > > > >  create mode 100644 drivers/soc/fsl/guts.c
> > > > > 
> > > > > --
> > > > > 2.1.0.27.g96db324
> > > > > 
> > > > Thanks, applied on my mmc tree for next!
> > > > 
> > > > I noticed that some DT compatibles weren't documented, according to
> > > > checkpatch. Please fix that asap!
> > > They are documented, in fsl/guts.txt (the file moved in patch 2/7):
> > > > 
> > > >  - compatible : Should define the compatible device type for
> > > >    global-utilities.
> > > >    Possible compatibles:
> > > >         "fsl,qoriq-device-config-1.0"
> > > >         "fsl,qoriq-device-config-2.0"
> > > >         "fsl,<chip>-device-config"
> > > >         "fsl,<chip>-guts"
> > > Checkpatch doesn't understand compatibles defined in such a way.
> > [Lu Yangbo-B47093] You're right, Scott. I dropped DT patch 'dt: bindings:
> > update Freescale DCFG compatible '
> > which fixed un-doc issue since Shaohui had done this on Shawn Guo's tree.
> > https://git.kernel.org/cgit/linux/kernel/git/shawnguo/linux.git/commit/?h
> > =imx/dt64&id=981034a2bfcaff5c95dafde24d7abfe7f9025c19
> > 
> > Thanks.
> [Lu Yangbo-B47093] Both 'fsl,<chip>-guts' and 'fsl,<chip>-dcfg' would have
> no un-doc issue after Shaohui's patch are pulled :)

I don't follow.  The link above points to a patch that addresses -dcfg and
-scfg, not -device-config or -guts -- and it also doesn't do it in a manner
that checkpatch will understand.

In any case, I wouldn't call this an "un-doc issue" -- it is documented -- but
rather a checkpatch-friendliness issue.

-Scott

