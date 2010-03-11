From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 00/27] Clean up of_platform drivers
Date: Thu, 11 Mar 2010 11:21:48 -0700
Message-ID: <20100311181604.13103.30088.stgit__8113.66308848864$1268331776$gmane$org@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:61349 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933553Ab0CKSWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:22:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct of_platform_driver unnecessarily duplicates the .owner and
.name fields from the encapsulated struct device_driver.  This patch
series goes through all of_platform drivers and makes it use the
device_driver instance so that the duplicate field can be removed.

Since every of_platform_driver is getting touched anyway, this series
takes the opportunity to also move the of_device_id match table out
of struct of_platform_driver and into struct device_driver proper.
This makes it possible for all bus types to make use of OF-style
binding when CONFIG_OF is set.

I've compile tested this on sparc, powerpc and microblaze.  It should
all be fully bisectable, and only the last patch removes the old
fields (ie. nothing should break without the last patch).

g.

---

Grant Likely (27):
      of: remove obsolete members from of_platform_driver
      arch/sparc/of: don't use deprecated field in of_platform_driver
      arch/powerpc/of: don't use deprecated field in of_platform_driver
      sound/of: don't use deprecated fields in of_platform_driver
      drivers/infiniband/of: don't use deprecated fields in of_platform_driver
      drivers/i2c/of: don't use deprecated field in of_platform_driver
      drivers/hwmon/of: don't use deprecated field in of_platform_driver
      drivers/mmc/of: don't use deprecated field in of_platform_driver
      drivers/pcmcia/of: don't use deprecated field in of_platform_driver
      drivers/parport/of: don't use deprecated field in of_platform_driver
      drivers/sbus/of: don't use deprecated field in of_platform_driver
      drivers/scsi/of: don't use deprecated field in of_platform_driver
      drivers/spi/of: don't use deprecated field in of_platform_driver
      drivers/serial/of: don't use deprecated field in of_platform_driver
      drivers/net/of: don't use deprecated field in of_platform_driver
      drivers/mtd/of: don't use deprecated field in of_platform_driver
      drivers/macintosh/of: don't use deprecated field in of_platform_driver
      drivers/input/of: don't use deprecated field in of_platform_driver
      drivers/atm/of: don't use deprecated field in of_platform_driver
      drivers/crypto/of: don't use deprecated field in of_platform_driver
      drivers/char/of: don't use deprecated field in of_platform_driver
      drivers/block/of: don't use deprecated field in of_platform_driver
      drivers/usb/of: don't use deprecated field in of_platform_driver
      drivers/video/of: don't use deprecated field in of_platform_driver
      drivers/watchdog/of: don't use deprecated .name and .owner in of_platform_driver
      drivers/gpio/of: don't use deprecated fields in of_platform_driver
      drivercore: Add of_match_table to the common device drivers


 arch/powerpc/kernel/ibmebus.c                 |    2 +-
 arch/powerpc/kernel/of_platform.c             |    3 ++-
 arch/powerpc/platforms/52xx/mpc52xx_gpio.c    |   14 ++++++++----
 arch/powerpc/platforms/52xx/mpc52xx_gpt.c     |    7 ++++--
 arch/powerpc/platforms/52xx/mpc52xx_lpbfifo.c |    8 ++++---
 arch/powerpc/platforms/82xx/ep8248e.c         |    3 ++-
 arch/powerpc/platforms/83xx/suspend.c         |    7 ++++--
 arch/powerpc/platforms/cell/axon_msi.c        |    7 +++---
 arch/powerpc/platforms/pasemi/gpio_mdio.c     |    7 +++---
 arch/powerpc/sysdev/axonram.c                 |    8 +++----
 arch/powerpc/sysdev/bestcomm/bestcomm.c       |   10 +++-----
 arch/powerpc/sysdev/fsl_msi.c                 |    7 ++++--
 arch/powerpc/sysdev/fsl_pmc.c                 |    7 ++++--
 arch/powerpc/sysdev/fsl_rio.c                 |    7 ++++--
 arch/powerpc/sysdev/pmi.c                     |    7 +++---
 arch/powerpc/sysdev/qe_lib/qe.c               |    7 ++++--
 arch/sparc/include/asm/parport.h              |    7 ++++--
 arch/sparc/kernel/apc.c                       |    7 ++++--
 arch/sparc/kernel/auxio_64.c                  |    7 +++---
 arch/sparc/kernel/central.c                   |   14 +++++++-----
 arch/sparc/kernel/chmc.c                      |    7 ++++--
 arch/sparc/kernel/pci_fire.c                  |    7 ++++--
 arch/sparc/kernel/pci_psycho.c                |    7 ++++--
 arch/sparc/kernel/pci_sabre.c                 |    7 ++++--
 arch/sparc/kernel/pci_schizo.c                |    7 ++++--
 arch/sparc/kernel/pci_sun4v.c                 |    7 ++++--
 arch/sparc/kernel/pmc.c                       |    7 ++++--
 arch/sparc/kernel/power.c                     |    7 +++---
 arch/sparc/kernel/time_32.c                   |    7 +++---
 arch/sparc/kernel/time_64.c                   |   21 ++++++++++--------
 drivers/ata/pata_of_platform.c                |    7 ++++--
 drivers/ata/sata_fsl.c                        |    7 ++++--
 drivers/atm/fore200e.c                        |    7 ++++--
 drivers/block/xsysace.c                       |    5 ++--
 drivers/char/hw_random/n2-drv.c               |    7 ++++--
 drivers/char/hw_random/pasemi-rng.c           |    7 ++++--
 drivers/char/ipmi/ipmi_si_intf.c              |    7 ++++--
 drivers/char/xilinx_hwicap/xilinx_hwicap.c    |    5 ++--
 drivers/crypto/amcc/crypto4xx_core.c          |    7 ++++--
 drivers/crypto/talitos.c                      |    7 ++++--
 drivers/dma/fsldma.c                          |   13 +++++++----
 drivers/dma/ppc4xx/adma.c                     |    2 +-
 drivers/edac/mpc85xx_edac.c                   |   30 ++++++++++---------------
 drivers/edac/ppc4xx_edac.c                    |   10 ++++----
 drivers/hwmon/ultra45_env.c                   |    7 ++++--
 drivers/i2c/busses/i2c-cpm.c                  |   10 ++++----
 drivers/i2c/busses/i2c-ibm_iic.c              |    7 ++++--
 drivers/i2c/busses/i2c-mpc.c                  |    8 +++----
 drivers/infiniband/hw/ehca/ehca_main.c        |    7 +++---
 drivers/input/misc/sparcspkr.c                |   14 ++++++++----
 drivers/input/serio/i8042-sparcio.h           |    7 ++++--
 drivers/input/serio/xilinx_ps2.c              |    7 ++++--
 drivers/leds/leds-gpio.c                      |    2 +-
 drivers/macintosh/macio_asic.c                |    5 ++--
 drivers/macintosh/smu.c                       |    7 ++++--
 drivers/macintosh/therm_pm72.c                |    7 ++++--
 drivers/macintosh/therm_windtunnel.c          |    7 ++++--
 drivers/mmc/host/sdhci-of-core.c              |    7 ++++--
 drivers/mtd/maps/physmap_of.c                 |    7 ++++--
 drivers/mtd/maps/sun_uflash.c                 |    7 ++++--
 drivers/mtd/nand/fsl_elbc_nand.c              |    5 +++-
 drivers/mtd/nand/fsl_upm.c                    |    7 ++++--
 drivers/mtd/nand/ndfc.c                       |    5 +++-
 drivers/mtd/nand/pasemi_nand.c                |    7 ++++--
 drivers/mtd/nand/socrates_nand.c              |    7 ++++--
 drivers/net/can/mscan/mpc5xxx_can.c           |    8 ++++---
 drivers/net/can/sja1000/sja1000_of_platform.c |    8 ++++---
 drivers/net/ehea/ehea_main.c                  |    7 ++++--
 drivers/net/fs_enet/fs_enet-main.c            |    7 ++++--
 drivers/net/fs_enet/mii-bitbang.c             |    7 ++++--
 drivers/net/fs_enet/mii-fec.c                 |    7 ++++--
 drivers/net/fsl_pq_mdio.c                     |    7 ++++--
 drivers/net/gianfar.c                         |   10 +++++---
 drivers/net/ibm_newemac/core.c                |    8 ++++---
 drivers/net/ibm_newemac/mal.c                 |    8 ++++---
 drivers/net/ibm_newemac/rgmii.c               |    8 ++++---
 drivers/net/ibm_newemac/tah.c                 |    8 ++++---
 drivers/net/ibm_newemac/zmii.c                |    8 ++++---
 drivers/net/ll_temac_main.c                   |    2 +-
 drivers/net/myri_sbus.c                       |    7 ++++--
 drivers/net/niu.c                             |    7 ++++--
 drivers/net/phy/mdio-gpio.c                   |    7 ++++--
 drivers/net/sunbmac.c                         |    7 ++++--
 drivers/net/sunhme.c                          |    7 ++++--
 drivers/net/sunlance.c                        |    7 ++++--
 drivers/net/sunqe.c                           |    7 ++++--
 drivers/net/ucc_geth.c                        |    7 ++++--
 drivers/net/xilinx_emaclite.c                 |    7 ++++--
 drivers/of/platform.c                         |   10 ++------
 drivers/parport/parport_sunbpp.c              |    7 ++++--
 drivers/pcmcia/electra_cf.c                   |    7 ++++--
 drivers/pcmcia/m8xx_pcmcia.c                  |    7 ++++--
 drivers/sbus/char/bbc_i2c.c                   |    7 ++++--
 drivers/sbus/char/display7seg.c               |    7 ++++--
 drivers/sbus/char/envctrl.c                   |    7 ++++--
 drivers/sbus/char/flash.c                     |    7 ++++--
 drivers/sbus/char/uctrl.c                     |    7 ++++--
 drivers/scsi/qlogicpti.c                      |    7 ++++--
 drivers/scsi/sun_esp.c                        |    7 ++++--
 drivers/serial/apbuart.c                      |    8 +++----
 drivers/serial/cpm_uart/cpm_uart_core.c       |    7 ++++--
 drivers/serial/mpc52xx_uart.c                 |    7 +++---
 drivers/serial/of_serial.c                    |    8 ++++---
 drivers/serial/sunhv.c                        |    7 ++++--
 drivers/serial/sunsab.c                       |    7 ++++--
 drivers/serial/sunsu.c                        |    7 ++++--
 drivers/serial/sunzilog.c                     |    7 ++++--
 drivers/serial/uartlite.c                     |    5 ++--
 drivers/serial/ucc_uart.c                     |    8 ++++---
 drivers/spi/mpc52xx_psc_spi.c                 |    4 +--
 drivers/spi/mpc52xx_spi.c                     |    8 ++++---
 drivers/spi/spi_mpc8xxx.c                     |    7 ++++--
 drivers/spi/spi_ppc4xx.c                      |    2 +-
 drivers/spi/xilinx_spi_of.c                   |    2 +-
 drivers/usb/gadget/fsl_qe_udc.c               |    7 ++++--
 drivers/usb/host/ehci-ppc-of.c                |    9 +++-----
 drivers/usb/host/ehci-xilinx-of.c             |    9 +++-----
 drivers/usb/host/fhci-hcd.c                   |    7 ++++--
 drivers/usb/host/isp1760-if.c                 |    7 ++++--
 drivers/usb/host/ohci-ppc-of.c                |   13 +++--------
 drivers/video/bw2.c                           |    7 ++++--
 drivers/video/cg14.c                          |    7 ++++--
 drivers/video/cg3.c                           |    7 ++++--
 drivers/video/cg6.c                           |    7 ++++--
 drivers/video/ffb.c                           |    7 ++++--
 drivers/video/fsl-diu-fb.c                    |    8 ++++---
 drivers/video/leo.c                           |    7 ++++--
 drivers/video/mb862xx/mb862xxfb.c             |    8 ++++---
 drivers/video/p9100.c                         |    7 ++++--
 drivers/video/platinumfb.c                    |    7 ++++--
 drivers/video/tcx.c                           |    7 ++++--
 drivers/video/xilinxfb.c                      |    5 ++--
 drivers/watchdog/cpwd.c                       |    7 ++++--
 drivers/watchdog/gef_wdt.c                    |    8 ++++---
 drivers/watchdog/mpc8xxx_wdt.c                |    8 +++----
 drivers/watchdog/riowd.c                      |    7 ++++--
 include/linux/device.h                        |    4 +++
 include/linux/of_platform.h                   |    4 ---
 sound/soc/fsl/mpc5200_psc_ac97.c              |    2 +-
 sound/soc/fsl/mpc5200_psc_i2s.c               |    2 +-
 sound/soc/fsl/mpc8610_hpcd.c                  |    8 ++++---
 sound/sparc/amd7930.c                         |    7 ++++--
 sound/sparc/cs4231.c                          |    7 ++++--
 sound/sparc/dbri.c                            |    7 ++++--
 144 files changed, 665 insertions(+), 380 deletions(-)

-- 
Signature
