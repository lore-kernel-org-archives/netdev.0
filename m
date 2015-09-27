From: huangdaode <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Subject: [PATCH net-next v4] net: Fix Hisilicon Network Subsystem Support Compilation
Date: Sun, 27 Sep 2015 15:22:44 +0800
Message-ID: <1443338564-185286-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<catalin.marinas-5wv7dgnIgG8@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	<liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>, <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <kenneth-lee-2012-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>,
	<xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch fixes the compilation error with arm allmodconfig, this error
generated due to unavailability of readq() on 32-bit platform which was
found during net-next daily compilation. In the same time, fix all the
hns drivers compilation warnings.

Signed-off-by: huangdaode <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: zhaungyuzeng <Yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: kenneth Lee <liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: yankejian <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c   |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h  |  4 ++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c   |  6 ++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h   |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c       | 17 -----------------
 6 files changed, 7 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index a8bd27b..95bf42a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -86,7 +86,7 @@ int hns_mac_get_sfp_prsnt(struct hns_mac_cb *mac_cb, int *sfp_prsnt)
 	if (!mac_cb->cpld_vaddr)
 		return -ENODEV;
 
-	*sfp_prsnt = !dsaf_read_b((u64)mac_cb->cpld_vaddr
+	*sfp_prsnt = !dsaf_read_b((u8 *)mac_cb->cpld_vaddr
 					+ MAC_SFP_PORT_OFFSET);
 
 	return 0;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index e0417c0..315b07e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -43,7 +43,7 @@ struct hns_mac_cb;
 #define DSAF_DUMP_REGS_NUM 504
 #define DSAF_STATIC_NUM 28
 
-#define DSAF_STATS_READ(p, offset) (*((u64 *)((u64)(p) + (offset))))
+#define DSAF_STATS_READ(p, offset) (*((u64 *)((u8 *)(p) + (offset))))
 
 enum hal_dsaf_mode {
 	HRD_DSAF_NO_DSAF_MODE	= 0x0,
@@ -302,7 +302,7 @@ struct dsaf_device {
 
 static inline void *hns_dsaf_dev_priv(const struct dsaf_device *dsaf_dev)
 {
-	return (void *)((u64)dsaf_dev + sizeof(*dsaf_dev));
+	return (void *)((u8 *)dsaf_dev + sizeof(*dsaf_dev));
 }
 
 struct dsaf_drv_tbl_tcam_key {
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
index 50f3427..05ea244 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -192,8 +192,7 @@ static void hns_rcb_ring_init(struct ring_pair_cb *ring_pair, int ring_type)
 		dsaf_write_dev(q, RCB_RING_RX_RING_BASEADDR_L_REG,
 			       (u32)dma);
 		dsaf_write_dev(q, RCB_RING_RX_RING_BASEADDR_H_REG,
-			       (u32)(dma >> 32));
-
+			       (u32)((dma >> 31) >> 1));
 		dsaf_write_dev(q, RCB_RING_RX_RING_BD_LEN_REG,
 			       bd_size_type);
 		dsaf_write_dev(q, RCB_RING_RX_RING_BD_NUM_REG,
@@ -204,8 +203,7 @@ static void hns_rcb_ring_init(struct ring_pair_cb *ring_pair, int ring_type)
 		dsaf_write_dev(q, RCB_RING_TX_RING_BASEADDR_L_REG,
 			       (u32)dma);
 		dsaf_write_dev(q, RCB_RING_TX_RING_BASEADDR_H_REG,
-			       (u32)(dma >> 32));
-
+			       (u32)((dma >> 31) >> 1));
 		dsaf_write_dev(q, RCB_RING_TX_RING_BD_LEN_REG,
 			       bd_size_type);
 		dsaf_write_dev(q, RCB_RING_TX_RING_BD_NUM_REG,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 6fc58ba..b475e1b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -967,6 +967,6 @@ static inline u32 dsaf_get_reg_field(void *base, u32 reg, u32 mask, u32 shift)
 	readb((__iomem unsigned char *)(addr))
 
 #define hns_mac_reg_read64(drv, offset) \
-	readq((__iomem void *)(((u64)(drv)->io_base + 0xc00 + (offset))))
+	readq((__iomem void *)(((u8 *)(drv)->io_base + 0xc00 + (offset))))
 
 #endif	/* _DSAF_REG_H */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
index fe7fa1d..dab5ecf 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
@@ -7,6 +7,7 @@
  * (at your option) any later version.
  */
 
+#include <asm-generic/io-64-nonatomic-hi-lo.h>
 #include <linux/of_mdio.h>
 #include "hns_dsaf_main.h"
 #include "hns_dsaf_mac.h"
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 0713ced..ce7f2e0 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -31,8 +31,6 @@
 #define NIC_TX_CLEAN_MAX_NUM 256
 #define NIC_RX_CLEAN_MAX_NUM 64
 
-#define RCB_ERR_PRINT_CYCLE 1000
-
 #define RCB_IRQ_NOT_INITED 0
 #define RCB_IRQ_INITED 1
 
@@ -434,21 +432,12 @@ out_bnum_err:
 
 	if (unlikely((!desc->rx.pkt_len) ||
 		     hnae_get_bit(bnum_flag, HNS_RXD_DROP_B))) {
-		if (!(ring->stats.err_pkt_len % RCB_ERR_PRINT_CYCLE))
-			netdev_dbg(ndev,
-				   "pkt_len(%u),drop(%u),%#llx,%#llx\n",
-				   le16_to_cpu(desc->rx.pkt_len),
-				   hnae_get_bit(bnum_flag, HNS_RXD_DROP_B),
-				   ((u64 *)desc)[0], ((u64 *)desc)[1]);
 		ring->stats.err_pkt_len++;
 		dev_kfree_skb_any(skb);
 		return -EFAULT;
 	}
 
 	if (unlikely(hnae_get_bit(bnum_flag, HNS_RXD_L2E_B))) {
-		if (!(ring->stats.l2_err % RCB_ERR_PRINT_CYCLE))
-			netdev_dbg(ndev, "L2 check err,%#llx,%#llx\n",
-				   ((u64 *)desc)[0], ((u64 *)desc)[1]);
 		ring->stats.l2_err++;
 		dev_kfree_skb_any(skb);
 		return -EFAULT;
@@ -459,12 +448,6 @@ out_bnum_err:
 
 	if (unlikely(hnae_get_bit(bnum_flag, HNS_RXD_L3E_B) ||
 		     hnae_get_bit(bnum_flag, HNS_RXD_L4E_B))) {
-		if (!(ring->stats.l3l4_csum_err % RCB_ERR_PRINT_CYCLE))
-			netdev_dbg(ndev,
-				   "check err(%#x),%#llx,%#llx\n",
-				   hnae_get_bit(bnum_flag, HNS_RXD_L3E_B) |
-				   hnae_get_bit(bnum_flag, HNS_RXD_L4E_B),
-				   ((u64 *)desc)[0], ((u64 *)desc)[1]);
 		ring->stats.l3l4_csum_err++;
 		return 0;
 	}
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
