From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 00/37] OF: move device node pointer into struct device.
Date: Thu, 11 Mar 2010 11:03:47 -0700
Message-ID: <20100311174830.4824.19820.stgit__37956.8216893405$1268333054$gmane$org@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:59367 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933454Ab0CKSDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:03:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently on OF enabled platforms, the device node pointer is stored in
both device.archdata.of_node (.prom_node on sparc), and in of_device.node
OF device tree support is being generalized to work on any platform, so
instead of adding the of_node pointer to each platform's archdata
individually, this patch series moves the of_node pointer into struct
device proper and fixes up all users to reference the new location.

The last 3 patches in this series remove the old .archdata.of_node,
.archdata.prom_node and of_device.node instances.

This series has been compile tested on powerpc, sparc and microblaze,
(allmodconfig used on sparc and powerpc) and boot tested on an mpc5200
powerpc.  All known (or at least all I could find) in-tree users of the
old names have been removed.

This series should also be fully bisectable.  After I collect acks, I
would like to get this whole series into linux-next to see if I've
missed any references, but I can probably hold off merging the last
three patches when the 2.6.35 merge window opens to give out of tree
users a bit more time to adapt.  In fact, I'd probably wait a few
extra days after pushing out the bulk of this series before I push the
last 3 patches into my linux-next branch to isolate the drivers that I
missed while fixing.

Cheers,
g.

---

Grant Likely (37):
      arch/sparc: Remove .archdata.of_node and use .of_node in struct device
      arch/microblaze: Remove .archdata.of_node and use .of_node in struct device
      arch/powerpc: Remove .archdata.of_node and use .of_node in struct device
      sound/sparc: use .dev.of_node instead of .node in struct of_device
      sound/soc: use .dev.of_node instead of .node in struct of_device
      sound/aoa: use .dev.of_node instead of .node in struct of_device
      drivers/of: use .of_node instead of .archdata.of_node in struct device
      drivers/cdrom: use .of_node instead of .archdata.of_node in struct device
      drivers/char: use .of_node instead of .archdata.of_node in struct device
      drivers/scsi: use .of_node instead of .archdata.of_node in struct device
      drivers/of: use .dev.of_node instead of .node in struct of_device
      drivers/mtd: use .dev.of_node instead of .node in struct of_device
      drivers/infiniband: use .dev.of_node instead of .node in struct of_device
      drivers/char: use .dev.of_node instead of .node in struct of_device
      drivers/i2c: use .dev.of_node instead of .node in struct of_device
      drivers/leds: use .dev.of_node instead of .node in struct of_device
      drivers/ata: use .dev.of_node instead of .node in struct of_device
      drivers/input: use .dev.of_node instead of .node in struct of_device
      drivers/serial: use .dev.of_node instead of .node in struct of_device
      drivers/pcmcia: use .dev.of_node instead of .node in struct of_device
      drivers/net: use .dev.of_node instead of .node in struct of_device
      drivers/sbus: use .dev.of_node instead of .node in struct of_device
      drivers/mmc: use .dev.of_node instead of .node in struct of_device
      drivers/spi: use .dev.of_node instead of .node in struct of_device
      drivers/macintosh: use .dev.of_node instead of .node in struct of_device
      drivers/usb: use .dev.of_node instead of .node in struct of_device
      drivers/scsi: use .dev.of_node instead of .node in struct of_device
      drivers/video: use .dev.of_node instead of .node in struct of_device
      drivers/atm: use .dev.of_node instead of .node in struct of_device
      drivers/watchdog: use .dev.of_node instead of .node in struct of_device
      drivers/serial: use .dev.of_node instead of .node in struct of_device
      arch/microblaze: use .dev.of_node instead of .node in struct of_device
      arch/powerpc: use .dev.of_node instead of .node in struct of_device
      arch/sparc: use .dev.of_node instead of .node in struct of_device
      of/sparc: use dev->of_node instead of dev->archdata.prom_node
      of: Eliminate dev_archdata_get_node()
      i2c/of: Allow device node to be passed via i2c_board_info


 arch/microblaze/include/asm/device.h          |   14 ------------
 arch/microblaze/include/asm/of_device.h       |    1 -
 arch/microblaze/kernel/of_device.c            |   12 ++++------
 arch/microblaze/kernel/of_platform.c          |    4 ++-
 arch/powerpc/include/asm/device.h             |   22 +++++++------------
 arch/powerpc/include/asm/macio.h              |    2 +-
 arch/powerpc/include/asm/of_device.h          |    1 -
 arch/powerpc/kernel/ibmebus.c                 |    4 ++-
 arch/powerpc/kernel/of_device.c               |   12 ++++------
 arch/powerpc/kernel/of_platform.c             |   16 +++++++-------
 arch/powerpc/kernel/pci-common.c              |    1 -
 arch/powerpc/kernel/vio.c                     |   17 +++++++--------
 arch/powerpc/platforms/52xx/mpc52xx_gpio.c    |    4 ++-
 arch/powerpc/platforms/52xx/mpc52xx_gpt.c     |   16 +++++++-------
 arch/powerpc/platforms/52xx/mpc52xx_lpbfifo.c |    6 +++--
 arch/powerpc/platforms/82xx/ep8248e.c         |    6 +++--
 arch/powerpc/platforms/83xx/suspend.c         |    2 +-
 arch/powerpc/platforms/cell/axon_msi.c        |    2 +-
 arch/powerpc/platforms/cell/iommu.c           |    5 ++--
 arch/powerpc/platforms/pasemi/gpio_mdio.c     |    2 +-
 arch/powerpc/platforms/pasemi/setup.c         |    4 ++-
 arch/powerpc/platforms/ps3/system-bus.c       |    1 -
 arch/powerpc/platforms/pseries/iommu.c        |    2 +-
 arch/powerpc/sysdev/axonram.c                 |    6 +++--
 arch/powerpc/sysdev/bestcomm/bestcomm.c       |    8 +++----
 arch/powerpc/sysdev/fsl_msi.c                 |   14 ++++++------
 arch/powerpc/sysdev/fsl_pmc.c                 |    2 +-
 arch/powerpc/sysdev/pmi.c                     |    2 +-
 arch/sparc/include/asm/device.h               |   15 -------------
 arch/sparc/include/asm/fb.h                   |    2 +-
 arch/sparc/include/asm/floppy_64.h            |    4 ++-
 arch/sparc/include/asm/of_device.h            |    1 -
 arch/sparc/include/asm/parport.h              |    2 +-
 arch/sparc/kernel/auxio_64.c                  |    2 +-
 arch/sparc/kernel/central.c                   |    4 ++-
 arch/sparc/kernel/chmc.c                      |   10 ++++-----
 arch/sparc/kernel/ioport.c                    |    2 +-
 arch/sparc/kernel/of_device_32.c              |   18 +++++++---------
 arch/sparc/kernel/of_device_64.c              |   29 ++++++++++++-------------
 arch/sparc/kernel/of_device_common.c          |    4 ++-
 arch/sparc/kernel/pci.c                       |   13 ++++-------
 arch/sparc/kernel/pci_common.c                |    9 ++++----
 arch/sparc/kernel/pci_fire.c                  |    4 ++-
 arch/sparc/kernel/pci_msi.c                   |   18 ++++++++--------
 arch/sparc/kernel/pci_psycho.c                |    4 ++-
 arch/sparc/kernel/pci_sabre.c                 |    4 ++-
 arch/sparc/kernel/pci_schizo.c                |   14 ++++++------
 arch/sparc/kernel/pci_sun4v.c                 |    8 +++----
 arch/sparc/kernel/power.c                     |    4 ++-
 arch/sparc/kernel/psycho_common.c             |    2 +-
 arch/sparc/kernel/sbus.c                      |   16 +++++++-------
 arch/sparc/kernel/time_32.c                   |    2 +-
 arch/sparc/kernel/time_64.c                   |    6 +++--
 drivers/ata/pata_macio.c                      |    2 +-
 drivers/ata/pata_of_platform.c                |    2 +-
 drivers/atm/fore200e.c                        |   16 ++++++++------
 drivers/cdrom/viocd.c                         |    2 +-
 drivers/char/hw_random/n2-drv.c               |    2 +-
 drivers/char/hw_random/pasemi-rng.c           |    2 +-
 drivers/char/ipmi/ipmi_si_intf.c              |    4 ++-
 drivers/char/viotape.c                        |    2 +-
 drivers/gpio/pca953x.c                        |    2 +-
 drivers/i2c/busses/i2c-mpc.c                  |   17 ++++++++-------
 drivers/i2c/i2c-core.c                        |    3 +++
 drivers/ide/pmac.c                            |   10 ++++-----
 drivers/infiniband/hw/ehca/ehca_main.c        |   11 +++++----
 drivers/input/serio/i8042-sparcio.h           |    2 +-
 drivers/input/serio/xilinx_ps2.c              |    8 +++----
 drivers/leds/leds-gpio.c                      |    2 +-
 drivers/macintosh/macio_asic.c                |   16 +++++++-------
 drivers/macintosh/macio_sysfs.c               |    6 +++--
 drivers/macintosh/rack-meter.c                |    4 ++-
 drivers/macintosh/therm_pm72.c                |    2 +-
 drivers/mmc/host/of_mmc_spi.c                 |    4 ++-
 drivers/mmc/host/sdhci-of-core.c              |    2 +-
 drivers/mtd/maps/physmap_of.c                 |    6 +++--
 drivers/mtd/maps/sun_uflash.c                 |    2 +-
 drivers/mtd/nand/fsl_elbc_nand.c              |    6 +++--
 drivers/mtd/nand/pasemi_nand.c                |    2 +-
 drivers/net/can/sja1000/sja1000_of_platform.c |    4 ++-
 drivers/net/ehea/ehea_main.c                  |   14 ++++++------
 drivers/net/greth.c                           |    3 ++-
 drivers/net/ibm_newemac/core.c                |   13 ++++++-----
 drivers/net/ibm_newemac/debug.c               |    9 ++++----
 drivers/net/ibm_newemac/debug.h               |    4 ++-
 drivers/net/ibm_newemac/mal.c                 |   28 ++++++++++++------------
 drivers/net/ibm_newemac/rgmii.c               |   12 +++++-----
 drivers/net/ibm_newemac/tah.c                 |    7 +++---
 drivers/net/ibm_newemac/zmii.c                |    9 ++++----
 drivers/net/myri_sbus.c                       |    2 +-
 drivers/net/niu.c                             |   10 ++++-----
 drivers/net/phy/mdio-gpio.c                   |    6 +++--
 drivers/net/sunbmac.c                         |    6 +++--
 drivers/net/sunhme.c                          |    8 +++----
 drivers/net/sunlance.c                        |    6 +++--
 drivers/net/sunqe.c                           |    6 +++--
 drivers/net/xilinx_emaclite.c                 |    8 +++----
 drivers/of/device.c                           |   20 +++++++++--------
 drivers/of/of_i2c.c                           |    4 ++-
 drivers/of/of_mdio.c                          |    5 ++--
 drivers/of/of_spi.c                           |    1 -
 drivers/pcmcia/electra_cf.c                   |    2 +-
 drivers/sbus/char/bbc_envctrl.c               |    4 ++-
 drivers/sbus/char/bbc_i2c.c                   |    4 ++-
 drivers/sbus/char/display7seg.c               |    2 +-
 drivers/sbus/char/envctrl.c                   |    2 +-
 drivers/sbus/char/flash.c                     |    4 ++-
 drivers/sbus/char/uctrl.c                     |    2 +-
 drivers/scsi/ibmvscsi/ibmvfc.c                |    2 +-
 drivers/scsi/ibmvscsi/ibmvscsi.c              |    2 +-
 drivers/scsi/qlogicpti.c                      |   10 ++++-----
 drivers/scsi/sun_esp.c                        |   16 +++++++-------
 drivers/serial/apbuart.c                      |    2 +-
 drivers/serial/mpc52xx_uart.c                 |    8 +++----
 drivers/serial/nwpserial.c                    |    2 +-
 drivers/serial/of_serial.c                    |    4 ++-
 drivers/serial/pmac_zilog.c                   |    2 +-
 drivers/serial/sunhv.c                        |    2 +-
 drivers/serial/sunsab.c                       |    6 +++--
 drivers/serial/sunsu.c                        |    6 +++--
 drivers/serial/sunzilog.c                     |    8 +++----
 drivers/serial/uartlite.c                     |    6 +++--
 drivers/spi/mpc52xx_psc_spi.c                 |   11 +++++----
 drivers/spi/mpc52xx_spi.c                     |   14 ++++++------
 drivers/spi/spi_mpc8xxx.c                     |    6 +++--
 drivers/usb/host/ehci-ppc-of.c                |    2 +-
 drivers/usb/host/isp1760-if.c                 |    2 +-
 drivers/usb/host/ohci-ppc-of.c                |    2 +-
 drivers/video/cg6.c                           |    2 +-
 drivers/video/ffb.c                           |    2 +-
 drivers/watchdog/cpwd.c                       |    2 +-
 include/linux/i2c.h                           |    4 +++
 sound/aoa/fabrics/layout.c                    |    2 +-
 sound/aoa/soundbus/core.c                     |    8 +++----
 sound/aoa/soundbus/i2sbus/control.c           |    2 +-
 sound/aoa/soundbus/i2sbus/core.c              |    4 ++-
 sound/aoa/soundbus/sysfs.c                    |    4 ++-
 sound/soc/fsl/mpc8610_hpcd.c                  |    2 +-
 sound/sparc/cs4231.c                          |    6 +++--
 sound/sparc/dbri.c                            |    2 +-
 140 files changed, 422 insertions(+), 458 deletions(-)

-- 
Signature
