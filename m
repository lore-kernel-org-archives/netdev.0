From: Wolfram Sang <wsa@the-dreams.de>
Subject: [PATCH 00/33] devm improvement series, part 1, take 2
Date: Thu, 16 May 2013 13:15:28 +0200
Message-ID: <1368702961-4325-1-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, alsa-devel@alsa-project.org,
 linux-usb@vger.kernel.org, Wolfram Sang <wsa@the-dreams.de>,
 Alexander Shishkin <alexander.shishkin@linux.intel.com>,
 Viresh Kumar <viresh.kumar@linaro.org>,
 Linus Walleij <linus.walleij@linaro.org>, Matt Mackall <mpm@selenic.com>,
 linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org,
 Jaroslav Kysela <perex@perex.cz>, linux-ide@vger.kernel.org,
 netdev@vger.kernel.org, linux-mtd@lists.infradead.org,
 linux-i2c@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>,
 Wan ZongShun <mcuos.com@gmail.com>, ac100@lists.launchpad.net,
 devel@driverdev.osuosl.org, Kukjin Kim <kgene.kim@samsung.com>,
 Russell King <linux@arm.linux.org.uk>,
 Herbert Xu <herbert@gondor.apana.org.au>,
 Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
 Stephen Warren <swarren@wwwdotorg.org>, "Rafael J. Wysocki" <rjw@sisk.pl>,
 cpufreq@vger.ke
To: linux-kernel@vger.kernel.org
Return-path: <devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel/>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: "devel" <devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Lately, I have been experimenting how to improve the devm interface to make
writing device drivers easier and less error prone while also getting rid of
its subtle issues. I think it has more potential but still needs work and
definately conistency, especiall in its usage.

The first thing I come up with is a low hanging fruit regarding
devm_ioremap_resouce(). This function already checks if the passed resource is
valid and gives an error message if not. So, we can remove similar checks from
the drivers and get rid of a bit of code and a number of inconsistent error
strings.

Unlike the RFC version, this series only removes the unneeded check iff
devm_ioremap_resource() follows platform_get_resource directly. The previous
version tried to shuffle code if needed, too, what lead to an embarrasing bug.
It turned out to me that shuffling code for all cases found will make the
automated script too complex, so I am unsure if an automated cleanup is the
proper tool for this case. Removing the easy stuff seems worthwhile to me,
though, so I post this series in a simplified form.

Despite various architectures and platform dependencies, I managed to compile
test 45 out of 57 modified files locally using heuristics and defconfigs.
If somebody knows how to create a minimal .config with a certain kconfig symbol
(and its dependencies) set, I'd love to hear about it.

Since this series looks quite different from the RFC (less files touched
mainly) I did not copy over the ACKs from the RFC, although a few people agreed
with the aproach basically (except the major flaw the old series had).

The repo is here [1]. I'd think it would be nice to have in 3.10. and sending a
pull request to Linus would be easiest, probably. Some non-buggy RFC patches
already slipped into subtrees, yet this won't cause any conflicts.

Looking forward to comments.

Thanks,

   Wolfram

[1] git://git.kernel.org/pub/scm/linux/kernel/git/wsa/linux.git devm_no_resource_check


Wolfram Sang (33):
  drivers/ata: don't check resource with devm_ioremap_resource
  drivers/char/hw_random: don't check resource with
    devm_ioremap_resource
  drivers/cpufreq: don't check resource with devm_ioremap_resource
  drivers/dma: don't check resource with devm_ioremap_resource
  drivers/gpio: don't check resource with devm_ioremap_resource
  drivers/gpu/drm/exynos: don't check resource with
    devm_ioremap_resource
  drivers/gpu/host1x/drm: don't check resource with
    devm_ioremap_resource
  drivers/i2c/busses: don't check resource with devm_ioremap_resource
  drivers/memory: don't check resource with devm_ioremap_resource
  drivers/mfd: don't check resource with devm_ioremap_resource
  drivers/misc: don't check resource with devm_ioremap_resource
  drivers/mtd/nand: don't check resource with devm_ioremap_resource
  drivers/net/ethernet/renesas: don't check resource with
    devm_ioremap_resource
  drivers/pinctrl: don't check resource with devm_ioremap_resource
  drivers/pwm: don't check resource with devm_ioremap_resource
  drivers/rtc: don't check resource with devm_ioremap_resource
  drivers/spi: don't check resource with devm_ioremap_resource
  drivers/staging/dwc2: don't check resource with devm_ioremap_resource
  drivers/staging/nvec: don't check resource with devm_ioremap_resource
  drivers/thermal: don't check resource with devm_ioremap_resource
  drivers/usb/chipidea: don't check resource with devm_ioremap_resource
  drivers/usb/gadget: don't check resource with devm_ioremap_resource
  drivers/usb/host: don't check resource with devm_ioremap_resource
  drivers/usb/phy: don't check resource with devm_ioremap_resource
  drivers/video/omap2: don't check resource with devm_ioremap_resource
  drivers/video/omap2/dss: don't check resource with
    devm_ioremap_resource
  drivers/w1/masters: don't check resource with devm_ioremap_resource
  drivers/watchdog: don't check resource with devm_ioremap_resource
  arch/arm/mach-tegra: don't check resource with devm_ioremap_resource
  arch/arm/plat-samsung: don't check resource with
    devm_ioremap_resource
  arch/mips/lantiq/xway: don't check resource with
    devm_ioremap_resource
  sound/soc/fsl: don't check resource with devm_ioremap_resource
  sound/soc/kirkwood: don't check resource with devm_ioremap_resource

 arch/arm/mach-tegra/tegra2_emc.c      |    5 -----
 arch/arm/plat-samsung/adc.c           |    5 -----
 arch/mips/lantiq/xway/gptu.c          |    4 ----
 drivers/ata/pata_ep93xx.c             |    5 -----
 drivers/char/hw_random/mxc-rnga.c     |    6 ------
 drivers/char/hw_random/omap-rng.c     |    5 -----
 drivers/cpufreq/kirkwood-cpufreq.c    |    4 ----
 drivers/dma/tegra20-apb-dma.c         |    5 -----
 drivers/gpio/gpio-mvebu.c             |    5 -----
 drivers/gpio/gpio-tegra.c             |    5 -----
 drivers/gpu/drm/exynos/exynos_hdmi.c  |    5 -----
 drivers/gpu/host1x/drm/dc.c           |    5 -----
 drivers/i2c/busses/i2c-s3c2410.c      |    5 -----
 drivers/i2c/busses/i2c-sirf.c         |    6 ------
 drivers/i2c/busses/i2c-tegra.c        |    5 -----
 drivers/memory/emif.c                 |    6 ------
 drivers/mfd/intel_msic.c              |    5 -----
 drivers/misc/atmel-ssc.c              |    5 -----
 drivers/mtd/nand/lpc32xx_mlc.c        |    5 -----
 drivers/net/ethernet/renesas/sh_eth.c |    5 -----
 drivers/pinctrl/pinctrl-coh901.c      |    5 -----
 drivers/pinctrl/pinctrl-exynos5440.c  |    5 -----
 drivers/pinctrl/pinctrl-samsung.c     |    5 -----
 drivers/pinctrl/pinctrl-xway.c        |    4 ----
 drivers/pwm/pwm-imx.c                 |    5 -----
 drivers/pwm/pwm-puv3.c                |    5 -----
 drivers/pwm/pwm-pxa.c                 |    5 -----
 drivers/pwm/pwm-tegra.c               |    5 -----
 drivers/pwm/pwm-tiecap.c              |    5 -----
 drivers/pwm/pwm-tiehrpwm.c            |    5 -----
 drivers/pwm/pwm-tipwmss.c             |    5 -----
 drivers/pwm/pwm-vt8500.c              |    5 -----
 drivers/rtc/rtc-nuc900.c              |    5 -----
 drivers/rtc/rtc-omap.c                |    5 -----
 drivers/rtc/rtc-s3c.c                 |    5 -----
 drivers/rtc/rtc-tegra.c               |    6 ------
 drivers/spi/spi-tegra20-sflash.c      |    5 -----
 drivers/staging/dwc2/platform.c       |    5 -----
 drivers/staging/nvec/nvec.c           |    5 -----
 drivers/thermal/armada_thermal.c      |   10 ----------
 drivers/thermal/dove_thermal.c        |    4 ----
 drivers/thermal/exynos_thermal.c      |    5 -----
 drivers/usb/chipidea/core.c           |    5 -----
 drivers/usb/gadget/bcm63xx_udc.c      |   10 ----------
 drivers/usb/host/ohci-nxp.c           |    6 ------
 drivers/usb/phy/phy-mv-u3d-usb.c      |    5 -----
 drivers/usb/phy/phy-mxs-usb.c         |    5 -----
 drivers/usb/phy/phy-samsung-usb2.c    |    5 -----
 drivers/usb/phy/phy-samsung-usb3.c    |    5 -----
 drivers/video/omap2/dss/hdmi.c        |    4 ----
 drivers/video/omap2/vrfb.c            |    5 -----
 drivers/w1/masters/omap_hdq.c         |    5 -----
 drivers/watchdog/ath79_wdt.c          |    5 -----
 drivers/watchdog/davinci_wdt.c        |    5 -----
 drivers/watchdog/imx2_wdt.c           |    5 -----
 sound/soc/fsl/imx-ssi.c               |    6 ------
 sound/soc/kirkwood/kirkwood-i2s.c     |    5 -----
 57 files changed, 296 deletions(-)

-- 
1.7.10.4
