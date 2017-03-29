From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] drivers: add explicit interrupt.h includes
Date: Wed, 29 Mar 2017 17:17:31 +0200
Message-ID: <20170329151731.11633-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:34424 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752264AbdC2PRQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 11:17:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These files all use functions declared in interrupt.h, but currently rely
on implicit inclusion of this file (via netns/xfrm.h).

That won't work anymore when the flow cache is removed so include that
header where needed.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/infiniband/hw/nes/nes.h                           | 1 +
 drivers/net/dsa/mv88e6xxx/global2.c                       | 1 +
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c                  | 1 +
 drivers/net/ethernet/amd/xgbe/xgbe-i2c.c                  | 1 +
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c                 | 1 +
 drivers/net/ethernet/broadcom/bgmac.c                     | 1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt.h                 | 2 ++
 drivers/net/ethernet/cavium/liquidio/lio_main.c           | 1 +
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c        | 1 +
 drivers/net/ethernet/ezchip/nps_enet.c                    | 1 +
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c              | 1 +
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c           | 1 +
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c | 1 +
 drivers/net/wireless/st/cw1200/cw1200_sdio.c              | 1 +
 drivers/usb/gadget/function/f_ncm.c                       | 1 +
 net/mac802154/ieee802154_i.h                              | 1 +
 net/smc/smc_ib.h                                          | 1 +
 17 files changed, 18 insertions(+)

diff --git a/drivers/infiniband/hw/nes/nes.h b/drivers/infiniband/hw/nes/nes.h
index 85acd0843b50..3f9e56e8b379 100644
--- a/drivers/infiniband/hw/nes/nes.h
+++ b/drivers/infiniband/hw/nes/nes.h
@@ -36,6 +36,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/inetdevice.h>
+#include <linux/interrupt.h>
 #include <linux/spinlock.h>
 #include <linux/kernel.h>
 #include <linux/delay.h>
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 0b8601f8536e..132559d46b95 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -13,6 +13,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/interrupt.h>
 #include <linux/irqdomain.h>
 #include "mv88e6xxx.h"
 #include "global2.h"
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 54593e03d821..c772420fa41c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -118,6 +118,7 @@
 #include <linux/spinlock.h>
 #include <linux/tcp.h>
 #include <linux/if_vlan.h>
+#include <linux/interrupt.h>
 #include <net/busy_poll.h>
 #include <linux/clk.h>
 #include <linux/if_ether.h>
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-i2c.c b/drivers/net/ethernet/amd/xgbe/xgbe-i2c.c
index 0c7088a426e9..417bdb5982a9 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-i2c.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-i2c.c
@@ -115,6 +115,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/interrupt.h>
 #include <linux/kmod.h>
 #include <linux/delay.h>
 #include <linux/completion.h>
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index 4c5b90eea4af..b672d9249539 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -114,6 +114,7 @@
  *     THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/kmod.h>
 #include <linux/mdio.h>
diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index e1a24ee6ab8b..ba4d2e145bb9 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -11,6 +11,7 @@
 
 #include <linux/bcma/bcma.h>
 #include <linux/etherdevice.h>
+#include <linux/interrupt.h>
 #include <linux/bcm47xx_nvram.h>
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index c7a5b84a5cb2..3cb07778a690 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -18,6 +18,8 @@
 #define DRV_VER_MIN	7
 #define DRV_VER_UPD	0
 
+#include <linux/interrupt.h>
+
 struct tx_bd {
 	__le32 tx_bd_len_flags_type;
 	#define TX_BD_TYPE					(0x3f << 0)
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index b22291906fcc..a8426d3d05d0 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -16,6 +16,7 @@
  * NONINFRINGEMENT.  See the GNU General Public License for more details.
  ***********************************************************************/
 #include <linux/module.h>
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/firmware.h>
 #include <net/vxlan.h>
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 89fd81abab9a..174d748b5928 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -16,6 +16,7 @@
  * NONINFRINGEMENT.  See the GNU General Public License for more details.
  ***********************************************************************/
 #include <linux/module.h>
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <net/vxlan.h>
 #include "liquidio_common.h"
diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index 992ebe973d25..70165fcbff9c 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -16,6 +16,7 @@
 
 #include <linux/module.h>
 #include <linux/etherdevice.h>
+#include <linux/interrupt.h>
 #include <linux/of_address.h>
 #include <linux/of_irq.h>
 #include <linux/of_net.h>
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index e372a5823480..60d9b6aaf63a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -19,6 +19,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/interrupt.h>
 #include <linux/aer.h>
 
 #include "fm10k.h"
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
index 040b28977ee7..18c184ee1f3c 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
@@ -13,6 +13,7 @@
 /* Qualcomm Technologies, Inc. EMAC SGMII Controller driver.
  */
 
+#include <linux/interrupt.h>
 #include <linux/iopoll.h>
 #include <linux/acpi.h>
 #include <linux/of_device.h>
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
index 5bc2ba214735..9b970dc2b922 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
@@ -21,6 +21,7 @@
 #include <linux/pci_ids.h>
 #include <linux/sched.h>
 #include <linux/completion.h>
+#include <linux/interrupt.h>
 #include <linux/scatterlist.h>
 #include <linux/mmc/sdio.h>
 #include <linux/mmc/core.h>
diff --git a/drivers/net/wireless/st/cw1200/cw1200_sdio.c b/drivers/net/wireless/st/cw1200/cw1200_sdio.c
index d3acc85932a5..709f56e5ad87 100644
--- a/drivers/net/wireless/st/cw1200/cw1200_sdio.c
+++ b/drivers/net/wireless/st/cw1200/cw1200_sdio.c
@@ -10,6 +10,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/interrupt.h>
 #include <linux/gpio.h>
 #include <linux/delay.h>
 #include <linux/mmc/host.h>
diff --git a/drivers/usb/gadget/function/f_ncm.c b/drivers/usb/gadget/function/f_ncm.c
index 224717e63a53..864819ff9a7d 100644
--- a/drivers/usb/gadget/function/f_ncm.c
+++ b/drivers/usb/gadget/function/f_ncm.c
@@ -16,6 +16,7 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/device.h>
 #include <linux/etherdevice.h>
diff --git a/net/mac802154/ieee802154_i.h b/net/mac802154/ieee802154_i.h
index 56ccffa3f2bf..62141dcec2d6 100644
--- a/net/mac802154/ieee802154_i.h
+++ b/net/mac802154/ieee802154_i.h
@@ -19,6 +19,7 @@
 #ifndef __IEEE802154_I_H
 #define __IEEE802154_I_H
 
+#include <linux/interrupt.h>
 #include <linux/mutex.h>
 #include <linux/hrtimer.h>
 #include <net/cfg802154.h>
diff --git a/net/smc/smc_ib.h b/net/smc/smc_ib.h
index a95f74bb5569..7e1f0e24d177 100644
--- a/net/smc/smc_ib.h
+++ b/net/smc/smc_ib.h
@@ -11,6 +11,7 @@
 #ifndef _SMC_IB_H
 #define _SMC_IB_H
 
+#include <linux/interrupt.h>
 #include <linux/if_ether.h>
 #include <rdma/ib_verbs.h>
 
-- 
2.10.2
