From: Ulf Hansson <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [v16, 0/7] Fix eSDHC host version register bug
Date: Wed, 9 Nov 2016 19:27:47 +0100
Message-ID: <CAPDyKFrcAN_pqgtGaUanfB2zh97zGcL23m5VDtJ3g==NJeRrfA@mail.gmail.com>
References: <1478661252-42439-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Xiaobo Xie <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>, Minghuan Lian <minghuan.lian-3arQi8VN3Tc@public.gmane.org>,
	linux-clk <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Qiang Zhao <qiang.zhao-3arQi8VN3Tc@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Jochen Friedrich <jochen-NIgtFMG+Po8@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mmc <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlZmR6Xm/wNWPw@public.gmane.org
To: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1478661252-42439-1-git-send-email-yangbo.lu-3arQi8VN3Tc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

- i2c-list

On 9 November 2016 at 04:14, Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org> wrote:
> This patchset is used to fix a host version register bug in the T4240-R1.0-R2.0
> eSDHC controller. To match the SoC version and revision, 15 previous version
> patchsets had tried many methods but all of them were rejected by reviewers.
> Such as
>         - dts compatible method
>         - syscon method
>         - ifdef PPC method
>         - GUTS driver getting SVR method
> Anrd suggested a soc_device_match method in v10, and this is the only available
> method left now. This v11 patchset introduces the soc_device_match interface in
> soc driver.
>
> The first four patches of Yangbo are to add the GUTS driver. This is used to
> register a soc device which contain soc version and revision information.
> The other three patches introduce the soc_device_match method in soc driver
> and apply it on esdhc driver to fix this bug.
>
> ---
> Changes for v15:
>         - Dropped patch 'dt: bindings: update Freescale DCFG compatible'
>           since the work had been done by below patch on ShawnGuo's linux tree.
>           'dt-bindings: fsl: add LS1043A/LS1046A/LS2080A compatible for SCFG
>            and DCFG'
>         - Fixed error code issue in guts driver
> Changes for v16:
>         - Dropped patch 'powerpc/fsl: move mpc85xx.h to include/linux/fsl'
>         - Added a bug-fix patch from Geert
> ---
>
> Arnd Bergmann (1):
>   base: soc: introduce soc_device_match() interface
>
> Geert Uytterhoeven (1):
>   base: soc: Check for NULL SoC device attributes
>
> Yangbo Lu (5):
>   ARM64: dts: ls2080a: add device configuration node
>   dt: bindings: move guts devicetree doc out of powerpc directory
>   soc: fsl: add GUTS driver for QorIQ platforms
>   MAINTAINERS: add entry for Freescale SoC drivers
>   mmc: sdhci-of-esdhc: fix host version for T4240-R1.0-R2.0
>
>  .../bindings/{powerpc => soc}/fsl/guts.txt         |   3 +
>  MAINTAINERS                                        |  11 +-
>  arch/arm64/boot/dts/freescale/fsl-ls2080a.dtsi     |   6 +
>  drivers/base/Kconfig                               |   1 +
>  drivers/base/soc.c                                 |  70 ++++++
>  drivers/mmc/host/Kconfig                           |   1 +
>  drivers/mmc/host/sdhci-of-esdhc.c                  |  20 ++
>  drivers/soc/Kconfig                                |   3 +-
>  drivers/soc/fsl/Kconfig                            |  18 ++
>  drivers/soc/fsl/Makefile                           |   1 +
>  drivers/soc/fsl/guts.c                             | 236 +++++++++++++++++++++
>  include/linux/fsl/guts.h                           | 125 ++++++-----
>  include/linux/sys_soc.h                            |   3 +
>  13 files changed, 447 insertions(+), 51 deletions(-)
>  rename Documentation/devicetree/bindings/{powerpc => soc}/fsl/guts.txt (91%)
>  create mode 100644 drivers/soc/fsl/Kconfig
>  create mode 100644 drivers/soc/fsl/guts.c
>
> --
> 2.1.0.27.g96db324
>

Thanks, applied on my mmc tree for next!

I noticed that some DT compatibles weren't documented, according to
checkpatch. Please fix that asap!

Kind regards
Ulf Hansson
