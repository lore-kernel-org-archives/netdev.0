From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH net-next] net: remove mm.h inclusion from netdevice.h
Date: Fri, 17 Jun 2011 00:01:34 +0300
Message-ID: <20110616210134.GA18026@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fujita.tomonori@lab.ntt.co.jp, linux-arch@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove linux/mm.h inclusion from netdevice.h -- it's unused (I've checked manually).

To prevent mm.h inclusion via other channels also extract "enum dma_data_direction"
definition into separate header. This tiny piece is what gluing netdevice.h with mm.h
via "netdevice.h => dmaengine.h => dma-mapping.h => scatterlist.h => mm.h".
Removal of mm.h from scatterlist.h was tried and was found not feasible
on most archs, so the link was cutoff earlier.

Hope people are OK with tiny include file.

Note, that mm_types.h is still dragged in, but it is a separate story.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 arch/arm/mach-davinci/board-mityomapl138.c        |    1 +
 arch/arm/mach-davinci/dm646x.c                    |    1 +
 arch/arm/mach-davinci/pm.c                        |    1 +
 arch/arm/mach-imx/dma-v1.c                        |    1 +
 arch/arm/mach-imx/mach-mx31_3ds.c                 |    1 +
 arch/arm/mach-iop13xx/setup.c                     |    1 +
 arch/arm/mach-mxs/devices/platform-auart.c        |    1 +
 arch/arm/mach-mxs/devices/platform-dma.c          |    1 +
 arch/arm/mach-mxs/devices/platform-fec.c          |    1 +
 arch/arm/plat-mxc/devices/platform-fec.c          |    1 +
 arch/arm/plat-mxc/devices/platform-fsl-usb2-udc.c |    1 +
 arch/arm/plat-mxc/devices/platform-imx-fb.c       |    1 +
 arch/arm/plat-mxc/devices/platform-ipu-core.c     |    1 +
 arch/arm/plat-mxc/devices/platform-mxc-ehci.c     |    1 +
 arch/arm/plat-mxc/devices/platform-mxc-mmc.c      |    1 +
 arch/arm/plat-nomadik/include/plat/ste_dma40.h    |    1 +
 arch/x86/kernel/tboot.c                           |    1 +
 crypto/async_tx/raid6test.c                       |    1 +
 drivers/dma/coh901318.c                           |    1 +
 drivers/dma/dmaengine.c                           |    1 +
 drivers/dma/dmatest.c                             |    1 +
 drivers/dma/ipu/ipu_idmac.c                       |    1 +
 drivers/dma/ste_dma40.c                           |    1 +
 drivers/media/dvb/mantis/mantis_ca.c              |    1 +
 drivers/media/dvb/mantis/mantis_evm.c             |    1 +
 drivers/media/dvb/mantis/mantis_hif.c             |    1 +
 drivers/media/dvb/mantis/mantis_ioc.c             |    1 +
 drivers/media/dvb/mantis/mantis_pcmcia.c          |    1 +
 drivers/media/dvb/mantis/mantis_uart.c            |    1 +
 drivers/media/dvb/mantis/mantis_vp1034.c          |    1 +
 drivers/mmc/host/tmio_mmc_dma.c                   |    1 +
 drivers/mtd/nand/atmel_nand.c                     |    1 +
 drivers/net/arm/ks8695net.c                       |    1 +
 drivers/net/can/janz-ican3.c                      |    1 +
 drivers/net/can/softing/softing_fw.c              |    1 +
 drivers/net/can/softing/softing_main.c            |    1 +
 drivers/net/ethoc.c                               |    1 +
 drivers/net/fec_mpc52xx.c                         |    1 +
 drivers/net/greth.c                               |    1 +
 drivers/net/irda/pxaficp_ir.c                     |    1 +
 drivers/net/ks8851_mll.c                          |    1 +
 drivers/net/sgiseeq.c                             |    1 +
 drivers/net/stmmac/dwmac1000_core.c               |    1 +
 drivers/net/stmmac/dwmac1000_dma.c                |    1 +
 drivers/net/stmmac/dwmac100_core.c                |    1 +
 drivers/net/stmmac/dwmac100_dma.c                 |    1 +
 drivers/net/stmmac/stmmac_ethtool.c               |    1 +
 drivers/net/stmmac/stmmac_mdio.c                  |    1 +
 drivers/net/usb/cdc-phonet.c                      |    1 +
 drivers/net/vxge/vxge-config.h                    |    1 +
 drivers/net/wireless/ath/ath5k/base.c             |    1 +
 drivers/net/wireless/ath/ath9k/beacon.c           |    1 +
 drivers/net/wireless/ath/ath9k/init.c             |    1 +
 drivers/net/wireless/ath/ath9k/recv.c             |    1 +
 drivers/net/wireless/ath/ath9k/xmit.c             |    1 +
 drivers/tty/serial/ifx6x60.c                      |    1 +
 drivers/usb/gadget/f_phonet.c                     |    1 +
 include/crypto/if_alg.h                           |    1 +
 include/linux/dma-direction.h                     |   13 +++++++++++++
 include/linux/dma-mapping.h                       |   10 +---------
 include/linux/dmaengine.h                         |    4 +++-
 include/linux/netdevice.h                         |    1 -
 net/sched/sch_netem.c                             |    1 +
 security/apparmor/lib.c                           |    1 +
 64 files changed, 77 insertions(+), 11 deletions(-)

--- a/arch/arm/mach-davinci/board-mityomapl138.c
+++ b/arch/arm/mach-davinci/board-mityomapl138.c
@@ -20,6 +20,7 @@
 #include <linux/spi/spi.h>
 #include <linux/spi/flash.h>
 
+#include <asm/io.h>
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
 #include <mach/common.h>
--- a/arch/arm/mach-davinci/dm646x.c
+++ b/arch/arm/mach-davinci/dm646x.c
@@ -8,6 +8,7 @@
  * is licensed "as is" without any warranty of any kind, whether express
  * or implied.
  */
+#include <linux/dma-mapping.h>
 #include <linux/init.h>
 #include <linux/clk.h>
 #include <linux/serial_8250.h>
--- a/arch/arm/mach-davinci/pm.c
+++ b/arch/arm/mach-davinci/pm.c
@@ -17,6 +17,7 @@
 
 #include <asm/cacheflush.h>
 #include <asm/delay.h>
+#include <asm/io.h>
 
 #include <mach/da8xx.h>
 #include <mach/sram.h>
--- a/arch/arm/mach-imx/dma-v1.c
+++ b/arch/arm/mach-imx/dma-v1.c
@@ -26,6 +26,7 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/interrupt.h>
+#include <linux/err.h>
 #include <linux/errno.h>
 #include <linux/clk.h>
 #include <linux/scatterlist.h>
--- a/arch/arm/mach-imx/mach-mx31_3ds.c
+++ b/arch/arm/mach-imx/mach-mx31_3ds.c
@@ -13,6 +13,7 @@
  */
 
 #include <linux/delay.h>
+#include <linux/dma-mapping.h>
 #include <linux/types.h>
 #include <linux/init.h>
 #include <linux/clk.h>
--- a/arch/arm/mach-iop13xx/setup.c
+++ b/arch/arm/mach-iop13xx/setup.c
@@ -17,6 +17,7 @@
  *
  */
 
+#include <linux/dma-mapping.h>
 #include <linux/serial_8250.h>
 #include <linux/io.h>
 #ifdef CONFIG_MTD_PHYSMAP
--- a/arch/arm/mach-mxs/devices/platform-auart.c
+++ b/arch/arm/mach-mxs/devices/platform-auart.c
@@ -6,6 +6,7 @@
  * the terms of the GNU General Public License version 2 as published by the
  * Free Software Foundation.
  */
+#include <linux/dma-mapping.h>
 #include <asm/sizes.h>
 #include <mach/mx23.h>
 #include <mach/mx28.h>
--- a/arch/arm/mach-mxs/devices/platform-dma.c
+++ b/arch/arm/mach-mxs/devices/platform-dma.c
@@ -6,6 +6,7 @@
  * Free Software Foundation.
  */
 #include <linux/compiler.h>
+#include <linux/dma-mapping.h>
 #include <linux/err.h>
 #include <linux/init.h>
 
--- a/arch/arm/mach-mxs/devices/platform-fec.c
+++ b/arch/arm/mach-mxs/devices/platform-fec.c
@@ -6,6 +6,7 @@
  * the terms of the GNU General Public License version 2 as published by the
  * Free Software Foundation.
  */
+#include <linux/dma-mapping.h>
 #include <asm/sizes.h>
 #include <mach/mx28.h>
 #include <mach/devices-common.h>
--- a/arch/arm/plat-mxc/devices/platform-fec.c
+++ b/arch/arm/plat-mxc/devices/platform-fec.c
@@ -6,6 +6,7 @@
  * the terms of the GNU General Public License version 2 as published by the
  * Free Software Foundation.
  */
+#include <linux/dma-mapping.h>
 #include <asm/sizes.h>
 #include <mach/hardware.h>
 #include <mach/devices-common.h>
--- a/arch/arm/plat-mxc/devices/platform-fsl-usb2-udc.c
+++ b/arch/arm/plat-mxc/devices/platform-fsl-usb2-udc.c
@@ -6,6 +6,7 @@
  * the terms of the GNU General Public License version 2 as published by the
  * Free Software Foundation.
  */
+#include <linux/dma-mapping.h>
 #include <mach/hardware.h>
 #include <mach/devices-common.h>
 
--- a/arch/arm/plat-mxc/devices/platform-imx-fb.c
+++ b/arch/arm/plat-mxc/devices/platform-imx-fb.c
@@ -6,6 +6,7 @@
  * the terms of the GNU General Public License version 2 as published by the
  * Free Software Foundation.
  */
+#include <linux/dma-mapping.h>
 #include <mach/hardware.h>
 #include <mach/devices-common.h>
 
--- a/arch/arm/plat-mxc/devices/platform-ipu-core.c
+++ b/arch/arm/plat-mxc/devices/platform-ipu-core.c
@@ -6,6 +6,7 @@
  * the terms of the GNU General Public License version 2 as published by the
  * Free Software Foundation.
  */
+#include <linux/dma-mapping.h>
 #include <mach/hardware.h>
 #include <mach/devices-common.h>
 
--- a/arch/arm/plat-mxc/devices/platform-mxc-ehci.c
+++ b/arch/arm/plat-mxc/devices/platform-mxc-ehci.c
@@ -6,6 +6,7 @@
  * the terms of the GNU General Public License version 2 as published by the
  * Free Software Foundation.
  */
+#include <linux/dma-mapping.h>
 #include <mach/hardware.h>
 #include <mach/devices-common.h>
 
--- a/arch/arm/plat-mxc/devices/platform-mxc-mmc.c
+++ b/arch/arm/plat-mxc/devices/platform-mxc-mmc.c
@@ -6,6 +6,7 @@
  * the terms of the GNU General Public License version 2 as published by the
  * Free Software Foundation.
  */
+#include <linux/dma-mapping.h>
 #include <mach/hardware.h>
 #include <mach/devices-common.h>
 
--- a/arch/arm/plat-nomadik/include/plat/ste_dma40.h
+++ b/arch/arm/plat-nomadik/include/plat/ste_dma40.h
@@ -10,6 +10,7 @@
 #define STE_DMA40_H
 
 #include <linux/dmaengine.h>
+#include <linux/scatterlist.h>
 #include <linux/workqueue.h>
 #include <linux/interrupt.h>
 
--- a/arch/x86/kernel/tboot.c
+++ b/arch/x86/kernel/tboot.c
@@ -36,6 +36,7 @@
 #include <asm/bootparam.h>
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
+#include <asm/swiotlb.h>
 #include <asm/fixmap.h>
 #include <asm/proto.h>
 #include <asm/setup.h>
--- a/crypto/async_tx/raid6test.c
+++ b/crypto/async_tx/raid6test.c
@@ -21,6 +21,7 @@
  */
 #include <linux/async_tx.h>
 #include <linux/gfp.h>
+#include <linux/mm.h>
 #include <linux/random.h>
 
 #undef pr
--- a/drivers/dma/coh901318.c
+++ b/drivers/dma/coh901318.c
@@ -11,6 +11,7 @@
 #include <linux/module.h>
 #include <linux/kernel.h> /* printk() */
 #include <linux/fs.h> /* everything... */
+#include <linux/scatterlist.h>
 #include <linux/slab.h> /* kmalloc() */
 #include <linux/dmaengine.h>
 #include <linux/platform_device.h>
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -45,6 +45,7 @@
  * See Documentation/dmaengine.txt for more details
  */
 
+#include <linux/dma-mapping.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/mm.h>
--- a/drivers/dma/dmatest.c
+++ b/drivers/dma/dmatest.c
@@ -8,6 +8,7 @@
  * published by the Free Software Foundation.
  */
 #include <linux/delay.h>
+#include <linux/dma-mapping.h>
 #include <linux/dmaengine.h>
 #include <linux/init.h>
 #include <linux/kthread.h>
--- a/drivers/dma/ipu/ipu_idmac.c
+++ b/drivers/dma/ipu/ipu_idmac.c
@@ -9,6 +9,7 @@
  * published by the Free Software Foundation.
  */
 
+#include <linux/dma-mapping.h>
 #include <linux/init.h>
 #include <linux/platform_device.h>
 #include <linux/err.h>
--- a/drivers/dma/ste_dma40.c
+++ b/drivers/dma/ste_dma40.c
@@ -6,6 +6,7 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
+#include <linux/dma-mapping.h>
 #include <linux/kernel.h>
 #include <linux/slab.h>
 #include <linux/dmaengine.h>
--- a/drivers/media/dvb/mantis/mantis_ca.c
+++ b/drivers/media/dvb/mantis/mantis_ca.c
@@ -22,6 +22,7 @@
 #include <linux/slab.h>
 #include <linux/sched.h>
 #include <linux/interrupt.h>
+#include <asm/io.h>
 
 #include "dmxdev.h"
 #include "dvbdev.h"
--- a/drivers/media/dvb/mantis/mantis_evm.c
+++ b/drivers/media/dvb/mantis/mantis_evm.c
@@ -23,6 +23,7 @@
 #include <linux/signal.h>
 #include <linux/sched.h>
 #include <linux/interrupt.h>
+#include <asm/io.h>
 
 #include "dmxdev.h"
 #include "dvbdev.h"
--- a/drivers/media/dvb/mantis/mantis_hif.c
+++ b/drivers/media/dvb/mantis/mantis_hif.c
@@ -23,6 +23,7 @@
 #include <linux/sched.h>
 
 #include <linux/interrupt.h>
+#include <asm/io.h>
 
 #include "dmxdev.h"
 #include "dvbdev.h"
--- a/drivers/media/dvb/mantis/mantis_ioc.c
+++ b/drivers/media/dvb/mantis/mantis_ioc.c
@@ -24,6 +24,7 @@
 #include <linux/signal.h>
 #include <linux/sched.h>
 #include <linux/interrupt.h>
+#include <asm/io.h>
 
 #include "dmxdev.h"
 #include "dvbdev.h"
--- a/drivers/media/dvb/mantis/mantis_pcmcia.c
+++ b/drivers/media/dvb/mantis/mantis_pcmcia.c
@@ -23,6 +23,7 @@
 #include <linux/signal.h>
 #include <linux/sched.h>
 #include <linux/interrupt.h>
+#include <asm/io.h>
 
 #include "dmxdev.h"
 #include "dvbdev.h"
--- a/drivers/media/dvb/mantis/mantis_uart.c
+++ b/drivers/media/dvb/mantis/mantis_uart.c
@@ -20,6 +20,7 @@
 
 #include <linux/kernel.h>
 #include <linux/spinlock.h>
+#include <asm/io.h>
 
 #include <linux/signal.h>
 #include <linux/sched.h>
--- a/drivers/media/dvb/mantis/mantis_vp1034.c
+++ b/drivers/media/dvb/mantis/mantis_vp1034.c
@@ -21,6 +21,7 @@
 #include <linux/signal.h>
 #include <linux/sched.h>
 #include <linux/interrupt.h>
+#include <asm/io.h>
 
 #include "dmxdev.h"
 #include "dvbdev.h"
--- a/drivers/mmc/host/tmio_mmc_dma.c
+++ b/drivers/mmc/host/tmio_mmc_dma.c
@@ -11,6 +11,7 @@
  */
 
 #include <linux/device.h>
+#include <linux/dma-mapping.h>
 #include <linux/dmaengine.h>
 #include <linux/mfd/tmio.h>
 #include <linux/mmc/host.h>
--- a/drivers/mtd/nand/atmel_nand.c
+++ b/drivers/mtd/nand/atmel_nand.c
@@ -22,6 +22,7 @@
  *
  */
 
+#include <linux/dma-mapping.h>
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -16,6 +16,7 @@
  *		  Vincent Sanders <vince@simtec.co.uk>
  */
 
+#include <linux/dma-mapping.h>
 #include <linux/module.h>
 #include <linux/ioport.h>
 #include <linux/netdevice.h>
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -22,6 +22,7 @@
 #include <linux/can/error.h>
 
 #include <linux/mfd/janz.h>
+#include <asm/io.h>
 
 /* the DPM has 64k of memory, organized into 256x 256 byte pages */
 #define DPM_NUM_PAGES		256
--- a/drivers/net/can/softing/softing_fw.c
+++ b/drivers/net/can/softing/softing_fw.c
@@ -20,6 +20,7 @@
 #include <linux/firmware.h>
 #include <linux/sched.h>
 #include <asm/div64.h>
+#include <asm/io.h>
 
 #include "softing.h"
 
--- a/drivers/net/can/softing/softing_main.c
+++ b/drivers/net/can/softing/softing_main.c
@@ -21,6 +21,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
+#include <asm/io.h>
 
 #include "softing.h"
 
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -11,6 +11,7 @@
  * Written by Thierry Reding <thierry.reding@avionic-design.de>
  */
 
+#include <linux/dma-mapping.h>
 #include <linux/etherdevice.h>
 #include <linux/crc32.h>
 #include <linux/interrupt.h>
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -14,6 +14,7 @@
  *
  */
 
+#include <linux/dma-mapping.h>
 #include <linux/module.h>
 
 #include <linux/kernel.h>
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -22,6 +22,7 @@
  *               Marko Isomaki
  */
 
+#include <linux/dma-mapping.h>
 #include <linux/module.h>
 #include <linux/uaccess.h>
 #include <linux/init.h>
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -12,6 +12,7 @@
  * Infra-red driver (SIR/FIR) for the PXA2xx embedded microprocessor
  *
  */
+#include <linux/dma-mapping.h>
 #include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
--- a/drivers/net/ks8851_mll.c
+++ b/drivers/net/ks8851_mll.c
@@ -35,6 +35,7 @@
 #include <linux/platform_device.h>
 #include <linux/delay.h>
 #include <linux/slab.h>
+#include <asm/io.h>
 
 #define	DRV_NAME	"ks8851_mll"
 
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -6,6 +6,7 @@
 
 #undef DEBUG
 
+#include <linux/dma-mapping.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/slab.h>
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -28,6 +28,7 @@
 
 #include <linux/crc32.h>
 #include <linux/slab.h>
+#include <asm/io.h>
 #include "dwmac1000.h"
 
 static void dwmac1000_core_init(void __iomem *ioaddr)
--- a/drivers/net/stmmac/dwmac1000_dma.c
+++ b/drivers/net/stmmac/dwmac1000_dma.c
@@ -26,6 +26,7 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
+#include <asm/io.h>
 #include "dwmac1000.h"
 #include "dwmac_dma.h"
 
--- a/drivers/net/stmmac/dwmac100_core.c
+++ b/drivers/net/stmmac/dwmac100_core.c
@@ -29,6 +29,7 @@
 *******************************************************************************/
 
 #include <linux/crc32.h>
+#include <asm/io.h>
 #include "dwmac100.h"
 
 static void dwmac100_core_init(void __iomem *ioaddr)
--- a/drivers/net/stmmac/dwmac100_dma.c
+++ b/drivers/net/stmmac/dwmac100_dma.c
@@ -28,6 +28,7 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
+#include <asm/io.h>
 #include "dwmac100.h"
 #include "dwmac_dma.h"
 
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -27,6 +27,7 @@
 #include <linux/interrupt.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <asm/io.h>
 
 #include "stmmac.h"
 #include "dwmac_dma.h"
--- a/drivers/net/stmmac/stmmac_mdio.c
+++ b/drivers/net/stmmac/stmmac_mdio.c
@@ -27,6 +27,7 @@
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/slab.h>
+#include <asm/io.h>
 
 #include "stmmac.h"
 
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -21,6 +21,7 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/gfp.h>
 #include <linux/usb.h>
--- a/drivers/net/vxge/vxge-config.h
+++ b/drivers/net/vxge/vxge-config.h
@@ -16,6 +16,7 @@
 #include <linux/hardirq.h>
 #include <linux/list.h>
 #include <linux/slab.h>
+#include <asm/io.h>
 
 #ifndef VXGE_CACHE_LINE_SIZE
 #define VXGE_CACHE_LINE_SIZE 128
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -42,6 +42,7 @@
 
 #include <linux/module.h>
 #include <linux/delay.h>
+#include <linux/dma-mapping.h>
 #include <linux/hardirq.h>
 #include <linux/if.h>
 #include <linux/io.h>
--- a/drivers/net/wireless/ath/ath9k/beacon.c
+++ b/drivers/net/wireless/ath/ath9k/beacon.c
@@ -14,6 +14,7 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#include <linux/dma-mapping.h>
 #include "ath9k.h"
 
 #define FUDGE 2
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -14,6 +14,7 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#include <linux/dma-mapping.h>
 #include <linux/slab.h>
 #include <linux/ath9k_platform.h>
 
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -14,6 +14,7 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#include <linux/dma-mapping.h>
 #include "ath9k.h"
 #include "ar9003_mac.h"
 
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -14,6 +14,7 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#include <linux/dma-mapping.h>
 #include "ath9k.h"
 #include "ar9003_mac.h"
 
--- a/drivers/tty/serial/ifx6x60.c
+++ b/drivers/tty/serial/ifx6x60.c
@@ -36,6 +36,7 @@
  *	you need to use this driver for another platform.
  *
  *****************************************************************************/
+#include <linux/dma-mapping.h>
 #include <linux/module.h>
 #include <linux/termios.h>
 #include <linux/tty.h>
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -20,6 +20,7 @@
  * 02110-1301 USA
  */
 
+#include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/kernel.h>
 #include <linux/device.h>
--- a/include/crypto/if_alg.h
+++ b/include/crypto/if_alg.h
@@ -16,6 +16,7 @@
 #include <linux/compiler.h>
 #include <linux/completion.h>
 #include <linux/if_alg.h>
+#include <linux/scatterlist.h>
 #include <linux/types.h>
 #include <net/sock.h>
 
new file mode 100644
--- /dev/null
+++ b/include/linux/dma-direction.h
@@ -0,0 +1,13 @@
+#ifndef _LINUX_DMA_DIRECTION_H
+#define _LINUX_DMA_DIRECTION_H
+/*
+ * These definitions mirror those in pci.h, so they can be used
+ * interchangeably with their PCI_ counterparts.
+ */
+enum dma_data_direction {
+	DMA_BIDIRECTIONAL = 0,
+	DMA_TO_DEVICE = 1,
+	DMA_FROM_DEVICE = 2,
+	DMA_NONE = 3,
+};
+#endif
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -4,17 +4,9 @@
 #include <linux/device.h>
 #include <linux/err.h>
 #include <linux/dma-attrs.h>
+#include <linux/dma-direction.h>
 #include <linux/scatterlist.h>
 
-/* These definitions mirror those in pci.h, so they can be used
- * interchangeably with their PCI_ counterparts */
-enum dma_data_direction {
-	DMA_BIDIRECTIONAL = 0,
-	DMA_TO_DEVICE = 1,
-	DMA_FROM_DEVICE = 2,
-	DMA_NONE = 3,
-};
-
 struct dma_map_ops {
 	void* (*alloc_coherent)(struct device *dev, size_t size,
 				dma_addr_t *dma_handle, gfp_t gfp);
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -23,7 +23,9 @@
 
 #include <linux/device.h>
 #include <linux/uio.h>
-#include <linux/dma-mapping.h>
+#include <linux/dma-direction.h>
+
+struct scatterlist;
 
 /**
  * typedef dma_cookie_t - an opaque DMA cookie
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -34,7 +34,6 @@
 #include <linux/pm_qos_params.h>
 #include <linux/timer.h>
 #include <linux/delay.h>
-#include <linux/mm.h>
 #include <asm/atomic.h>
 #include <asm/cache.h>
 #include <asm/byteorder.h>
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -13,6 +13,7 @@
  *		Catalin(ux aka Dino) BOIE <catab at umbrella dot ro>
  */
 
+#include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/types.h>
--- a/security/apparmor/lib.c
+++ b/security/apparmor/lib.c
@@ -12,6 +12,7 @@
  * License.
  */
 
+#include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/vmalloc.h>
