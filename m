From: Philipp Zabel <p.zabel@pengutronix.de>
Subject: [PATCH 000/102] Convert drivers to explicit reset API
Date: Wed, 19 Jul 2017 17:25:04 +0200
Message-ID: <20170719152646.25903-1-p.zabel@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Philipp Zabel <p.zabel@pengutronix.de>,
        "David S. Miller" <davem@davemloft.net>,
        =?UTF-8?q?Emilio=20L=C3=B3pez?= <emilio@elopez.com.ar>,
        Adrian Hunter <adrian.hunter@intel.com>,
        Alan Stern <stern@rowland.harvard.edu>,
        Alan Tull <atull@kernel.org>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Andrew Lunn <andrew@lunn.ch>, Ben Skeggs <bskeggs@redhat.com>,
        Benjamin Gaignard <benjamin.gaignard@linaro.org>,
        Bin Liu <b-liu@ti.com>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        Brian Norris <computersforpeace@gmail.com>,
        Chanwoo Choi <cw00.choi@samsung.com>,
        Chen Feng <puck.chen@hisilicon.com>,
        Chen-Yu Tsai <wens@csie.org>,
        Corentin Labbe <clabbe.montjoie@gmail.com>,
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

The reset control API has two modes: exclusive access, where the driver
expects to have full and immediate control over the state of the reset
line, and shared (clock-like) access, where drivers only request reset
deassertion while active, but don't care about the state of the reset line
while inactive.

Commit a53e35db70d1 ("reset: Ensure drivers are explicit when requesting
reset lines") started to transition the reset control request API calls
to explicitly state whether the driver needs exclusive or shared reset
control behavior.

This series converts all drivers that currently implicitly request
exclusive reset controls to the corresponding explicit API call. It is,
for the most part, generated from the following semantic patch:

@@
expression rstc, dev, id;
@@
-rstc = reset_control_get(dev, id);
+rstc = reset_control_get_exclusive(dev, id);
@@
expression rstc, dev, id;
@@
-rstc = reset_control_get_optional(dev, id);
+rstc = reset_control_get_optional_exclusive(dev, id);
@@
expression rstc, node, id;
@@
-rstc = of_reset_control_get(node, id);
+rstc = of_reset_control_get_exclusive(node, id);
@@
expression rstc, node, index;
@@
-rstc = of_reset_control_get_by_index(node, index);
+rstc = of_reset_control_get_exclusive_by_index(node, index);
@@
expression rstc, dev, id;
@@
-rstc = devm_reset_control_get(dev, id);
+rstc = devm_reset_control_get_exclusive(dev, id);
@@
expression rstc, dev, id;
@@
-rstc = devm_reset_control_get_optional(dev, id);
+rstc = devm_reset_control_get_optional_exclusive(dev, id);
@@
expression rstc, dev, index;
@@
-rstc = devm_reset_control_get_by_index(dev, index);
+rstc = devm_reset_control_get_exclusive_by_index(dev, index);

After all driver patches are applied, the temporary transition helpers
can be removed.

regards
Philipp

Philipp Zabel (102):
  ARM: rockchip: explicitly request exclusive reset control
  ARM: socfpga: explicitly request exclusive reset control
  MIPS: pci-mt7620: explicitly request exclusive reset control
  ahci: st: explicitly request exclusive reset control
  ata: sata_gemini: explicitly request exclusive reset control
  ata: ahci_tegra: explicitly request exclusive reset control
  bus: sunxi-rsb: explicitly request exclusive reset control
  bus: tegra-gmi: explicitly request exclusive reset control
  clk: sunxi: explicitly request exclusive reset control
  clk: tegra: explicitly request exclusive reset control
  clocksource/drivers/timer-stm32: explicitly request exclusive reset
    control
  clocksource/drivers/sun5i: explicitly request exclusive reset control
  crypto: rockchip: explicitly request exclusive reset control
  crypto: sun4i-ss - request exclusive reset control
  PM / devfreq: tegra: explicitly request exclusive reset control
  dmaengine: stm32-dma: explicitly request exclusive reset control
  dmaengine: sun6i: explicitly request exclusive reset control
  dmaengine: tegra-apb: explicitly request exclusive reset control
  drm: kirin: explicitly request exclusive reset control
  drm/nouveau/tegra: explicitly request exclusive reset control
  drm/rockchip: explicitly request exclusive reset control
  drm/sti: explicitly request exclusive reset control
  drm/stm: explicitly request exclusive reset control
  drm/sun4i: explicitly request exclusive reset control
  drm/tegra: explicitly request exclusive reset control
  gpu: host1x: explicitly request exclusive reset control
  i2c: mv64xxx: explicitly request exclusive reset control
  i2c: stm32f4: explicitly request exclusive reset control
  i2c: sun6i-pw2i: explicitly request exclusive reset control
  i2c: tegra: explicitly request exclusive reset control
  iio: adc: rockchip_saradc: explicitly request exclusive reset control
  iio: dac: stm32-dac-core: explicitly request exclusive reset control
  Input: tegra-kbc - request exclusive reset control
  coda: explicitly request exclusive reset control
  st-rc: explicitly request exclusive reset control
  stm32-dcmi: explicitly request exclusive reset control
  rc: sunxi-cir: explicitly request exclusive reset control
  mmc: dw_mmc: explicitly request exclusive reset control
  mmc: sdhci-st: explicitly request exclusive reset control
  mmc: sunxi: explicitly request exclusive reset control
  mmc: tegra: explicitly request exclusive reset control
  mtd: nand: sunxi: explicitly request exclusive reset control
  mtd: spi-nor: stm32-quadspi: explicitly request exclusive reset
    control
  net: dsa: mt7530: explicitly request exclusive reset control
  net: ethernet: hisi_femac: explicitly request exclusive reset control
  net: ethernet: hix5hd2_gmac: explicitly request exclusive reset
    control
  net: stmmac: explicitly request exclusive reset control
  net: stmmac: dwc-qos: explicitly request exclusive reset control
  ath10k: explicitly request exclusive reset control
  nvmem: lpc18xx-eeprom: explicitly request exclusive reset control
  PCI: dwc: pcie-qcom: explicitly request exclusive reset control
  PCI: imx6: explicitly request exclusive reset control
  PCI: tegra: explicitly request exclusive reset control
  PCI: rockchip: explicitly request exclusive reset control
  phy: berlin-usb: explicitly request exclusive reset control
  PCI: mediatek: explicitly request exclusive reset control
  phy: qcom-usb-hs: explicitly request exclusive reset control
  phy: rockchip-pcie: explicitly request exclusive reset control
  phy: rockchip-typec: explicitly request exclusive reset control
  phy: rockchip-usb: explicitly request exclusive reset control
  phy: sun4i-usb: explicitly request exclusive reset control
  phy: sun9i-usb: explicitly request exclusive reset control
  phy: tegra: explicitly request exclusive reset control
  phy: qcom-qmp: explicitly request exclusive reset control
  phy: qcom-qusb2: explicitly request exclusive reset control
  pinctrl: stm32: explicitly request exclusive reset control
  pinctrl: sunxi: explicitly request exclusive reset control
  pinctrl: tegra: explicitly request exclusive reset control
  pwm: hibvt: explicitly request exclusive reset control
  pwm: tegra: explicitly request exclusive reset control
  remoteproc/keystone: explicitly request exclusive reset control
  remoteproc: qcom: explicitly request exclusive reset control
  remoteproc: st: explicitly request exclusive reset control
  soc: mediatek: PMIC wrap: explicitly request exclusive reset control
  soc/tegra: pmc: explicitly request exclusive reset control
  spi: stm32: explicitly request exclusive reset control
  spi: sun6i: explicitly request exclusive reset control
  spi: tegra20-slink: explicitly request exclusive reset control
  spi: tegra114: explicitly request exclusive reset control
  spi: tegra20-sflash: explicitly request exclusive reset control
  staging: nvec: explicitly request exclusive reset control
  thermal: rockchip: explicitly request exclusive reset control
  thermal: tegra: explicitly request exclusive reset control
  serial: 8250_dw: explicitly request exclusive reset control
  serial: tegra: explicitly request exclusive reset control
  usb: chipidea: msm: explicitly request exclusive reset control
  usb: dwc2: explicitly request exclusive reset control
  usb: host: ehci-tegra: explicitly request exclusive reset control
  usb: host: xhci-tegra: explicitly request exclusive reset control
  usb: musb: sunxi: explicitly request exclusive reset control
  usb: phy: msm: explicitly request exclusive reset control
  usb: phy: qcom-8x16-usb: explicitly request exclusive reset control
  watchdog: asm9260: explicitly request exclusive reset control
  watchdog: mt7621: explicitly request exclusive reset control
  watchdog: rt2880: explicitly request exclusive reset control
  watchdog: zx2967: explicitly request exclusive reset control
  ASoC: img: explicitly request exclusive reset control
  ASoC: stm32: explicitly request exclusive reset control
  ASoC: sun4i: explicitly request exclusive reset control
  ASoC: tegra: explicitly request exclusive reset control
  Documentation: devres: add explicit exclusive/shared reset control
    request calls
  reset: finish transition to explicit exclusive reset control requests

 Documentation/driver-model/devres.txt              |  7 ++-
 arch/arm/mach-rockchip/platsmp.c                   |  2 +-
 arch/mips/pci/pci-mt7620.c                         |  2 +-
 drivers/ata/ahci_st.c                              |  6 +--
 drivers/ata/ahci_tegra.c                           |  8 ++--
 drivers/ata/sata_gemini.c                          |  4 +-
 drivers/bus/sunxi-rsb.c                            |  2 +-
 drivers/bus/tegra-gmi.c                            |  2 +-
 drivers/clk/sunxi/clk-sun9i-mmc.c                  |  2 +-
 drivers/clk/tegra/clk-dfll.c                       |  2 +-
 drivers/clocksource/timer-stm32.c                  |  2 +-
 drivers/clocksource/timer-sun5i.c                  |  2 +-
 drivers/crypto/rockchip/rk3288_crypto.c            |  2 +-
 drivers/crypto/sunxi-ss/sun4i-ss-core.c            |  3 +-
 drivers/devfreq/tegra-devfreq.c                    |  2 +-
 drivers/dma/stm32-dma.c                            |  2 +-
 drivers/dma/sun6i-dma.c                            |  2 +-
 drivers/dma/tegra20-apb-dma.c                      |  2 +-
 drivers/fpga/altera-hps2fpga.c                     |  3 +-
 drivers/gpu/drm/hisilicon/kirin/kirin_drm_ade.c    |  2 +-
 drivers/gpu/drm/nouveau/nvkm/engine/device/tegra.c |  2 +-
 drivers/gpu/drm/rockchip/analogix_dp-rockchip.c    |  2 +-
 drivers/gpu/drm/rockchip/cdn-dp-core.c             |  8 ++--
 drivers/gpu/drm/rockchip/dw-mipi-dsi.c             |  2 +-
 drivers/gpu/drm/rockchip/rockchip_drm_vop.c        |  4 +-
 drivers/gpu/drm/sti/sti_hdmi.c                     |  2 +-
 drivers/gpu/drm/sti/sti_hqvdp.c                    |  2 +-
 drivers/gpu/drm/sti/sti_tvout.c                    |  2 +-
 drivers/gpu/drm/stm/ltdc.c                         |  2 +-
 drivers/gpu/drm/sun4i/sun4i_backend.c              |  4 +-
 drivers/gpu/drm/sun4i/sun4i_tcon.c                 |  2 +-
 drivers/gpu/drm/sun4i/sun4i_tv.c                   |  2 +-
 drivers/gpu/drm/sun4i/sun6i_drc.c                  |  2 +-
 drivers/gpu/drm/sun4i/sun8i_mixer.c                |  2 +-
 drivers/gpu/drm/tegra/dc.c                         |  2 +-
 drivers/gpu/drm/tegra/dpaux.c                      |  3 +-
 drivers/gpu/drm/tegra/dsi.c                        |  2 +-
 drivers/gpu/drm/tegra/gr3d.c                       |  6 +--
 drivers/gpu/drm/tegra/hdmi.c                       |  2 +-
 drivers/gpu/drm/tegra/sor.c                        |  2 +-
 drivers/gpu/host1x/dev.c                           |  2 +-
 drivers/i2c/busses/i2c-mv64xxx.c                   |  2 +-
 drivers/i2c/busses/i2c-stm32f4.c                   |  2 +-
 drivers/i2c/busses/i2c-sun6i-p2wi.c                |  2 +-
 drivers/i2c/busses/i2c-tegra.c                     |  2 +-
 drivers/iio/adc/rockchip_saradc.c                  |  3 +-
 drivers/iio/dac/stm32-dac-core.c                   |  2 +-
 drivers/input/keyboard/tegra-kbc.c                 |  2 +-
 drivers/media/platform/coda/coda-common.c          |  3 +-
 drivers/media/platform/stm32/stm32-dcmi.c          |  2 +-
 drivers/media/rc/st_rc.c                           |  2 +-
 drivers/media/rc/sunxi-cir.c                       |  2 +-
 drivers/mmc/host/dw_mmc.c                          |  2 +-
 drivers/mmc/host/sdhci-st.c                        |  2 +-
 drivers/mmc/host/sdhci-tegra.c                     |  3 +-
 drivers/mmc/host/sunxi-mmc.c                       |  3 +-
 drivers/mtd/nand/sunxi_nand.c                      |  2 +-
 drivers/mtd/spi-nor/stm32-quadspi.c                |  2 +-
 drivers/net/dsa/mt7530.c                           |  3 +-
 drivers/net/ethernet/hisilicon/hisi_femac.c        |  4 +-
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c      |  6 +--
 .../ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c    |  2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c  |  3 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  4 +-
 drivers/net/wireless/ath/ath10k/ahb.c              | 15 ++++---
 drivers/nvmem/lpc18xx_eeprom.c                     |  2 +-
 drivers/pci/dwc/pci-imx6.c                         |  7 +--
 drivers/pci/dwc/pcie-qcom.c                        | 40 +++++++++--------
 drivers/pci/host/pci-tegra.c                       |  6 +--
 drivers/pci/host/pcie-mediatek.c                   |  2 +-
 drivers/pci/host/pcie-rockchip.c                   | 15 ++++---
 drivers/phy/allwinner/phy-sun4i-usb.c              |  2 +-
 drivers/phy/allwinner/phy-sun9i-usb.c              |  4 +-
 drivers/phy/marvell/phy-berlin-usb.c               |  2 +-
 drivers/phy/qualcomm/phy-qcom-qmp.c                |  4 +-
 drivers/phy/qualcomm/phy-qcom-qusb2.c              |  3 +-
 drivers/phy/qualcomm/phy-qcom-usb-hs.c             |  3 +-
 drivers/phy/rockchip/phy-rockchip-pcie.c           |  2 +-
 drivers/phy/rockchip/phy-rockchip-typec.c          |  6 +--
 drivers/phy/rockchip/phy-rockchip-usb.c            |  2 +-
 drivers/phy/tegra/xusb-tegra210.c                  |  4 +-
 drivers/phy/tegra/xusb.c                           |  2 +-
 drivers/pinctrl/stm32/pinctrl-stm32.c              |  2 +-
 drivers/pinctrl/sunxi/pinctrl-sun6i-a31-r.c        |  2 +-
 drivers/pinctrl/sunxi/pinctrl-sun8i-a23-r.c        |  2 +-
 drivers/pinctrl/tegra/pinctrl-tegra-xusb.c         |  2 +-
 drivers/pwm/pwm-hibvt.c                            |  2 +-
 drivers/pwm/pwm-tegra.c                            |  2 +-
 drivers/remoteproc/keystone_remoteproc.c           |  2 +-
 drivers/remoteproc/qcom_q6v5_pil.c                 |  3 +-
 drivers/remoteproc/st_remoteproc.c                 |  6 ++-
 drivers/reset/core.c                               |  2 +-
 drivers/soc/mediatek/mtk-pmic-wrap.c               |  5 ++-
 drivers/soc/tegra/pmc.c                            |  2 +-
 drivers/spi/spi-stm32.c                            |  2 +-
 drivers/spi/spi-sun6i.c                            |  2 +-
 drivers/spi/spi-tegra114.c                         |  2 +-
 drivers/spi/spi-tegra20-sflash.c                   |  2 +-
 drivers/spi/spi-tegra20-slink.c                    |  2 +-
 drivers/staging/nvec/nvec.c                        |  2 +-
 drivers/thermal/rockchip_thermal.c                 |  3 +-
 drivers/thermal/tegra/soctherm.c                   |  3 +-
 drivers/tty/serial/8250/8250_dw.c                  |  2 +-
 drivers/tty/serial/serial-tegra.c                  |  2 +-
 drivers/usb/chipidea/ci_hdrc_msm.c                 |  2 +-
 drivers/usb/dwc2/platform.c                        |  3 +-
 drivers/usb/host/ehci-tegra.c                      |  5 ++-
 drivers/usb/host/xhci-tegra.c                      |  6 ++-
 drivers/usb/musb/sunxi.c                           |  2 +-
 drivers/usb/phy/phy-msm-usb.c                      |  4 +-
 drivers/usb/phy/phy-qcom-8x16-usb.c                |  2 +-
 drivers/watchdog/asm9260_wdt.c                     |  2 +-
 drivers/watchdog/mt7621_wdt.c                      |  2 +-
 drivers/watchdog/rt2880_wdt.c                      |  2 +-
 drivers/watchdog/zx2967_wdt.c                      |  2 +-
 include/linux/reset.h                              | 50 ----------------------
 sound/soc/img/img-i2s-in.c                         |  2 +-
 sound/soc/img/img-i2s-out.c                        |  2 +-
 sound/soc/img/img-parallel-out.c                   |  2 +-
 sound/soc/img/img-spdif-in.c                       |  2 +-
 sound/soc/img/img-spdif-out.c                      |  2 +-
 sound/soc/stm/stm32_i2s.c                          |  2 +-
 sound/soc/stm/stm32_sai.c                          |  2 +-
 sound/soc/stm/stm32_spdifrx.c                      |  2 +-
 sound/soc/sunxi/sun4i-codec.c                      |  3 +-
 sound/soc/sunxi/sun4i-i2s.c                        |  2 +-
 sound/soc/sunxi/sun4i-spdif.c                      |  3 +-
 sound/soc/tegra/tegra30_ahub.c                     |  4 +-
 128 files changed, 226 insertions(+), 235 deletions(-)

-- 
2.11.0

Cc: "David S. Miller" <davem@davemloft.net>
Cc: "Emilio López" <emilio@elopez.com.ar>
Cc: Adrian Hunter <adrian.hunter@intel.com>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Alan Tull <atull@kernel.org>
Cc: Alexandre Torgue <alexandre.torgue@st.com>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Ben Skeggs <bskeggs@redhat.com>
Cc: Benjamin Gaignard <benjamin.gaignard@linaro.org>
Cc: Bin Liu <b-liu@ti.com>
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Boris Brezillon <boris.brezillon@free-electrons.com>
Cc: Brian Norris <computersforpeace@gmail.com>
Cc: Chanwoo Choi <cw00.choi@samsung.com>
Cc: Chen Feng <puck.chen@hisilicon.com>
Cc: Chen-Yu Tsai <wens@csie.org>
Cc: Corentin Labbe <clabbe.montjoie@gmail.com>
Cc: Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Daniel Lezcano <daniel.lezcano@linaro.org>
Cc: David Airlie <airlied@linux.ie>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Cc: Eduardo Valentin <edubezval@gmail.com>
Cc: Felipe Balbi <balbi@kernel.org>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Guenter Roeck <linux@roeck-us.net>
Cc: Hartmut Knaack <knaack.h@gmx.de>
Cc: Heiko Stuebner <heiko@sntech.de>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Jaehoon Chung <jh80.chung@samsung.com>
Cc: Jiri Slaby <jslaby@suse.com>
Cc: Joachim Eastwood <manabian@gmail.com>
Cc: John Youn <johnyoun@synopsys.com>
Cc: Jon Hunter <jonathanh@nvidia.com>
Cc: Jonathan Cameron <jic23@kernel.org>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Jonathan Hunter <jonathanh@nvidia.com>
Cc: Kalle Valo <kvalo@qca.qualcomm.com>
Cc: Kishon Vijay Abraham I <kishon@ti.com>
Cc: Kyungmin Park <kyungmin.park@samsung.com>
Cc: Lars-Peter Clausen <lars@metafoo.de>
Cc: Laxman Dewangan <ldewangan@nvidia.com>
Cc: Lee Jones <lee.jones@linaro.org>
Cc: Liam Girdwood <lgirdwood@gmail.com>
Cc: Linus Walleij <linus.walleij@linaro.org>
Cc: Lucas Stach <l.stach@pengutronix.de>
Cc: Marc Dietrich <marvin24@gmx.de>
Cc: Marek Vasut <marek.vasut@gmail.com>
Cc: Mark Brown <broonie@kernel.org>
Cc: Mark Yao <mark.yao@rock-chips.com>
Cc: Mathias Nyman <mathias.nyman@intel.com>
Cc: Matthias Brugger <matthias.bgg@gmail.com>
Cc: Maxime Coquelin <mcoquelin.stm32@gmail.com>
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: Michael Turquette <mturquette@baylibre.com>
Cc: Moritz Fischer <moritz.fischer@ettus.com>
Cc: MyungJoo Ham <myungjoo.ham@samsung.com>
Cc: Ohad Ben-Cohen <ohad@wizery.com>
Cc: Patrice Chotard <patrice.chotard@st.com>
Cc: Peter Chen <Peter.Chen@nxp.com>
Cc: Peter De Schrijver <pdeschrijver@nvidia.com>
Cc: Peter Meerwald-Stadler <pmeerw@pmeerw.net>
Cc: Philippe Cornu <philippe.cornu@st.com>
Cc: Prashant Gaikwad <pgaikwad@nvidia.com>
Cc: Rakesh Iyer <riyer@nvidia.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Richard Weinberger <richard@nod.at>
Cc: Richard Zhu <hongxing.zhu@nxp.com>
Cc: Rongrong Zou <zourongrong@gmail.com>
Cc: Ryder Lee <ryder.lee@mediatek.com>
Cc: Salil Mehta <salil.mehta@huawei.com>
Cc: Shawn Lin <shawn.lin@rock-chips.com>
Cc: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
Cc: Stanimir Varbanov <svarbanov@mm-sol.com>
Cc: Stephen Boyd <sboyd@codeaurora.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Thierry Reding <thierry.reding@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ulf Hansson <ulf.hansson@linaro.org>
Cc: Vincent Abriou <vincent.abriou@st.com>
Cc: Vinod Koul <vinod.koul@intel.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Cc: Wim Van Sebroeck <wim@iguana.be>
Cc: Wolfram Sang <wsa@the-dreams.de>
Cc: Xinliang Liu <z.liuxinliang@hisilicon.com>
Cc: Xinwei Kong <kong.kongxinwei@hisilicon.com>
Cc: Yannick Fertre <yannick.fertre@st.com>
Cc: Yisen Zhuang <yisen.zhuang@huawei.com>
Cc: Zhang Rui <rui.zhang@intel.com>
Cc: alsa-devel@alsa-project.org
Cc: ath10k@lists.infradead.org
Cc: devel@driverdev.osuosl.org
Cc: dmaengine@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-arm-msm@vger.kernel.org
Cc: linux-clk@vger.kernel.org
Cc: linux-crypto@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-fpga@vger.kernel.org
Cc: linux-gpio@vger.kernel.org
Cc: linux-i2c@vger.kernel.org
Cc: linux-ide@vger.kernel.org
Cc: linux-iio@vger.kernel.org
Cc: linux-input@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-media@vger.kernel.org
Cc: linux-mediatek@lists.infradead.org
Cc: linux-mips@linux-mips.org
Cc: linux-mmc@vger.kernel.org
Cc: linux-mtd@lists.infradead.org
Cc: linux-pci@vger.kernel.org
Cc: linux-pm@vger.kernel.org
Cc: linux-pwm@vger.kernel.org
Cc: linux-remoteproc@vger.kernel.org
Cc: linux-rockchip@lists.infradead.org
Cc: linux-serial@vger.kernel.org
Cc: linux-spi@vger.kernel.org
Cc: linux-tegra@vger.kernel.org
Cc: linux-usb@vger.kernel.org
Cc: linux-watchdog@vger.kernel.org
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: nouveau@lists.freedesktop.org
