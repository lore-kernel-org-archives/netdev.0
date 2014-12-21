From: Wolfram Sang <wsa@the-dreams.de>
Subject: [PATCH 00/28] remove .owner for most platform_drivers: the missing bits
Date: Sun, 21 Dec 2014 22:14:21 +0100
Message-ID: <1419196495-9626-1-git-send-email-wsa@the-dreams.de>
Cc: Wolfram Sang <wsa@the-dreams.de>, alsa-devel@alsa-project.org,
	ath5k-devel@lists.ath5k.org,
	Dan Williams <dan.j.williams@intel.com>,
	devicetree@vger.kernel.org, dmaengine@vger.kernel.org,
	dri-devel@lists.freedesktop.org, iommu@lists.linux-foundation.org,
	linux-arm-kernel@lists.infradead.org, linux-gpio@vger.kernel.org,
	linux-mips@linux-mips.org, linux-omap@vger.kernel.org,
	linux-pci@vger.kernel.org, linux-pm@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-rockchip@lists.infradead.org,
	linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-serial@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-watchdog@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, openipmi-developer@lists.sourceforge.net,
	rtc-linux@googlegroups.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Generated with coccinelle. The big cleanup was pulled in this merge window.
This series catches the bits fallen through. The patches shall go in via the
subsystem trees. If possible for 3.19 to increase consistency I'd say, but you
decide, of course.

cocci-file used:

@match1@
declarer name module_platform_driver;
declarer name module_platform_driver_probe;
declarer name for_each_node_by_type;
identifier __driver;
@@
(
	module_platform_driver(__driver);
|
	module_platform_driver_probe(__driver, ...);
)

@fix1 depends on match1@
identifier match1.__driver;
@@
	static struct platform_driver __driver = {
		.driver = {
-			.owner = THIS_MODULE,
		}
	};

@match2@
identifier __driver;
@@
(
	platform_driver_register(&__driver)
|
	platform_driver_probe(&__driver, ...)
|
	platform_create_bundle(&__driver, ...)
)

@fix2 depends on match2@
identifier match2.__driver;
@@
	static struct platform_driver __driver = {
		.driver = {
-			.owner = THIS_MODULE,
		}
	};

Thanks again to Julia Lawall for support. And hey, we fixed a coccinelle bug on
the way :)


Wolfram Sang (28):
  ARM: mach-exynos: drop owner assignment from platform_drivers
  mips: lantiq: xway: drop owner assignment from platform_drivers
  mips: pci: drop owner assignment from platform_drivers
  char: ipmi: drop owner assignment from platform_drivers
  cpufreq: drop owner assignment from platform_drivers
  dma: drop owner assignment from platform_drivers
  gpio: drop owner assignment from platform_drivers
  gpu: drm: rockchip: drop owner assignment from platform_drivers
  iommu: drop owner assignment from platform_drivers
  net: ethernet: stmicro: stmmac: drop owner assignment from
    platform_drivers
  net: wireless: ath: ath5k: drop owner assignment from platform_drivers
  of: drop owner assignment from platform_drivers
  pci: host: drop owner assignment from platform_drivers
  phy: drop owner assignment from platform_drivers
  pinctrl: intel: drop owner assignment from platform_drivers
  rtc: drop owner assignment from platform_drivers
  scsi: drop owner assignment from platform_drivers
  thermal: drop owner assignment from platform_drivers
  thermal: int340x_thermal: drop owner assignment from platform_drivers
  tty: serial: 8250: drop owner assignment from platform_drivers
  usb: gadget: udc: bdc: drop owner assignment from platform_drivers
  watchdog: drop owner assignment from platform_drivers
  ASoC: intel: drop owner assignment from platform_drivers
  ASoC: intel: sst: drop owner assignment from platform_drivers
  ASoC: omap: drop owner assignment from platform_drivers
  ASoC: pxa: drop owner assignment from platform_drivers
  ASoC: samsung: drop owner assignment from platform_drivers
  macintosh: drop owner assignment from platform_drivers

 arch/arm/mach-exynos/pmu.c                            | 1 -
 arch/mips/lantiq/xway/vmmc.c                          | 1 -
 arch/mips/pci/pci-ar2315.c                            | 1 -
 arch/mips/pci/pci-rt2880.c                            | 1 -
 drivers/char/ipmi/ipmi_powernv.c                      | 1 -
 drivers/cpufreq/ls1x-cpufreq.c                        | 1 -
 drivers/dma/at_xdmac.c                                | 1 -
 drivers/gpio/gpio-vf610.c                             | 1 -
 drivers/gpu/drm/rockchip/rockchip_drm_drv.c           | 1 -
 drivers/iommu/rockchip-iommu.c                        | 1 -
 drivers/macintosh/windfarm_pm112.c                    | 1 -
 drivers/macintosh/windfarm_pm72.c                     | 1 -
 drivers/macintosh/windfarm_rm31.c                     | 1 -
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 1 -
 drivers/net/wireless/ath/ath5k/ahb.c                  | 1 -
 drivers/of/unittest.c                                 | 1 -
 drivers/pci/host/pci-layerscape.c                     | 1 -
 drivers/phy/phy-armada375-usb2.c                      | 1 -
 drivers/phy/phy-berlin-usb.c                          | 1 -
 drivers/phy/phy-miphy28lp.c                           | 1 -
 drivers/pinctrl/intel/pinctrl-cherryview.c            | 1 -
 drivers/rtc/rtc-opal.c                                | 1 -
 drivers/scsi/atari_scsi.c                             | 1 -
 drivers/scsi/mac_scsi.c                               | 1 -
 drivers/scsi/sun3_scsi.c                              | 1 -
 drivers/thermal/int340x_thermal/int3400_thermal.c     | 1 -
 drivers/thermal/int340x_thermal/int3402_thermal.c     | 1 -
 drivers/thermal/rockchip_thermal.c                    | 1 -
 drivers/tty/serial/8250/8250_omap.c                   | 1 -
 drivers/usb/gadget/udc/bdc/bdc_core.c                 | 1 -
 drivers/watchdog/cadence_wdt.c                        | 1 -
 drivers/watchdog/meson_wdt.c                          | 1 -
 sound/soc/intel/bytcr_dpcm_rt5640.c                   | 1 -
 sound/soc/intel/cht_bsw_rt5672.c                      | 1 -
 sound/soc/intel/sst/sst_acpi.c                        | 1 -
 sound/soc/omap/omap-hdmi-audio.c                      | 1 -
 sound/soc/pxa/spitz.c                                 | 1 -
 sound/soc/samsung/arndale_rt5631.c                    | 1 -
 38 files changed, 38 deletions(-)

-- 
2.1.3
