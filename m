From: Wolfram Sang <wsa@the-dreams.de>
Subject: [PATCH 00/27] devm cleanup, part #1, take #3
Date: Tue, 23 Jul 2013 20:01:33 +0200
Message-ID: <1374602524-3398-1-git-send-email-wsa@the-dreams.de>
Cc: Wolfram Sang <wsa@the-dreams.de>, alsa-devel@alsa-project.org,
        Bjorn Helgaas <bhelgaas@google.com>,
        Daniel Lezcano <daniel.lezcano@linaro.org>,
        Dan Williams <djbw@fb.com>,
        David Woodhouse <dwmw2@infradead.org>,
        devel@driverdev.osuosl.org,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        dri-devel@lists.freedesktop.org,
        Eduardo Valentin <eduardo.valentin@ti.com>,
        Eric Miao <eric.y.miao@gmail.com>, Felipe Balbi <balbi@ti.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Grant Likely <grant.likely@linaro.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Haojian Zhuang <haojian.zhuang@gmail.com>,
        "James E.J. Bottomley" <JBottomley@parallels.com>,
        Jaroslav Kysela <perex@perex.cz>,
        Liam Girdwood <lgirdwood@gmail.com>,
        Linus Walleij <linus.walleij@linaro.
To: linux-kernel@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Here is another bit of cleaning up the devm usage. It is again removing the
resource check with devm_ioremap_resource, because a) new drivers came in and
b) coccinelle had a bug and missed to find a couple of occasions. Unlike last
time, I think it is better if these patches go in via the subsystem trees to
reduce merge conflicts. And there is one driver which I fixed manually because
the original code needed some bigger update. All is based on v3.11-rc2 and the
branch can be found at:

git://git.kernel.org/pub/scm/linux/kernel/git/wsa/linux.git devm_no_resource_check

Other things which happened: I wanted to get rid of devm_request_and_ioremap,
luckily other people are already working on it. Hooray! I already sent a patch
series picking another low hanging fruit, i.e. drivers can skip devm_pinctrl
handling if they are using only the default pin setup. And not devm related,
there is still my proposal to rename INIT_COMPLETION to reinit_completion, that
probably needs some more persistence... Yay, so much to clean up \o/

Regards,

   Wolfram


Wolfram Sang (27):
  arch/mips/lantiq/xway: don't check resource with
    devm_ioremap_resource
  drivers/amba: don't check resource with devm_ioremap_resource
  drivers/cpuidle: don't check resource with devm_ioremap_resource
  drivers/dma: don't check resource with devm_ioremap_resource
  drivers/gpu/host1x/drm: don't check resource with
    devm_ioremap_resource
  drivers/i2c/busses: don't check resource with devm_ioremap_resource
  drivers/input/serio: don't check resource with devm_ioremap_resource
  drivers/iommu: don't check resource with devm_ioremap_resource
  drivers/media/platform: don't check resource with
    devm_ioremap_resource
  drivers/memory: don't check resource with devm_ioremap_resource
  drivers/mtd/nand: don't check resource with devm_ioremap_resource
  drivers/net/ethernet/stmicro/stmmac: don't check resource with
    devm_ioremap_resource
  drivers/pci/host: don't check resource with devm_ioremap_resource
  drivers/pinctrl: don't check resource with devm_ioremap_resource
  drivers/pwm: don't check resource with devm_ioremap_resource
  drivers/scsi/ufs: don't check resource with devm_ioremap_resource
  drivers/spi: don't check resource with devm_ioremap_resource
  drivers/staging/imx-drm: don't check resource with
    devm_ioremap_resource
  drivers/usb/phy: don't check resource with devm_ioremap_resource
  drivers/watchdog: don't check resource with devm_ioremap_resource
  sound/soc/au1x: don't check resource with devm_ioremap_resource
  sound/soc/cirrus: don't check resource with devm_ioremap_resource
  sound/soc/nuc900: don't check resource with devm_ioremap_resource
  sound/soc/pxa: don't check resource with devm_ioremap_resource
  sound/soc/tegra: don't check resource with devm_ioremap_resource
  sound/soc/txx9: don't check resource with devm_ioremap_resource
  thermal: ti-bandgap: cleanup resource allocation

 arch/mips/lantiq/xway/dma.c                        |    4 ----
 drivers/amba/tegra-ahb.c                           |    2 --
 drivers/cpuidle/cpuidle-kirkwood.c                 |    3 ---
 drivers/dma/mmp_pdma.c                             |    3 ---
 drivers/dma/mmp_tdma.c                             |    3 ---
 drivers/gpu/host1x/drm/hdmi.c                      |    3 ---
 drivers/i2c/busses/i2c-stu300.c                    |    3 ---
 drivers/input/serio/olpc_apsp.c                    |    3 ---
 drivers/iommu/tegra-smmu.c                         |    2 --
 drivers/media/platform/coda.c                      |    5 -----
 drivers/memory/tegra20-mc.c                        |    2 --
 drivers/memory/tegra30-mc.c                        |    2 --
 drivers/mtd/nand/mxc_nand.c                        |    5 -----
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    3 ---
 drivers/pci/host/pcie-designware.c                 |   12 ------------
 drivers/pinctrl/pinctrl-imx.c                      |    3 ---
 drivers/pinctrl/pinctrl-rockchip.c                 |    5 -----
 drivers/pinctrl/pinctrl-u300.c                     |    3 ---
 drivers/pwm/pwm-lpc32xx.c                          |    3 ---
 drivers/pwm/pwm-renesas-tpu.c                      |    5 -----
 drivers/scsi/ufs/ufshcd-pltfrm.c                   |    6 ------
 drivers/spi/spi-bcm2835.c                          |    6 ------
 drivers/staging/imx-drm/imx-tve.c                  |    5 -----
 drivers/thermal/ti-soc-thermal/ti-bandgap.c        |   20 ++++----------------
 drivers/usb/phy/phy-rcar-usb.c                     |    5 -----
 drivers/watchdog/nuc900_wdt.c                      |    5 -----
 drivers/watchdog/ts72xx_wdt.c                      |   10 ----------
 sound/soc/au1x/psc-ac97.c                          |    3 ---
 sound/soc/cirrus/ep93xx-ac97.c                     |    3 ---
 sound/soc/cirrus/ep93xx-i2s.c                      |    3 ---
 sound/soc/nuc900/nuc900-ac97.c                     |    3 ---
 sound/soc/pxa/mmp-sspa.c                           |    3 ---
 sound/soc/tegra/tegra20_ac97.c                     |    7 -------
 sound/soc/txx9/txx9aclc-ac97.c                     |    3 ---
 34 files changed, 4 insertions(+), 152 deletions(-)

-- 
1.7.10.4
