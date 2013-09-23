From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/10] can: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 15:11:28 -0700
Message-ID: <5570169a078375fa8662adeb2a7f24c1ae718bfb.1379974101.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/can/mscan/mscan.h     |  6 +++---
 drivers/net/can/softing/softing.h | 24 ++++++++++++------------
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/can/mscan/mscan.h b/drivers/net/can/mscan/mscan.h
index 9c24d60..e98abb9 100644
--- a/drivers/net/can/mscan/mscan.h
+++ b/drivers/net/can/mscan/mscan.h
@@ -297,8 +297,8 @@ struct mscan_priv {
 	struct napi_struct napi;
 };
 
-extern struct net_device *alloc_mscandev(void);
-extern int register_mscandev(struct net_device *dev, int mscan_clksrc);
-extern void unregister_mscandev(struct net_device *dev);
+struct net_device *alloc_mscandev(void);
+int register_mscandev(struct net_device *dev, int mscan_clksrc);
+void unregister_mscandev(struct net_device *dev);
 
 #endif /* __MSCAN_H__ */
diff --git a/drivers/net/can/softing/softing.h b/drivers/net/can/softing/softing.h
index afd7d85..35f0622 100644
--- a/drivers/net/can/softing/softing.h
+++ b/drivers/net/can/softing/softing.h
@@ -71,34 +71,34 @@ struct softing {
 	} id;
 };
 
-extern int softing_default_output(struct net_device *netdev);
+int softing_default_output(struct net_device *netdev);
 
-extern ktime_t softing_raw2ktime(struct softing *card, u32 raw);
+ktime_t softing_raw2ktime(struct softing *card, u32 raw);
 
-extern int softing_chip_poweron(struct softing *card);
+int softing_chip_poweron(struct softing *card);
 
-extern int softing_bootloader_command(struct softing *card, int16_t cmd,
-		const char *msg);
+int softing_bootloader_command(struct softing *card, int16_t cmd,
+			       const char *msg);
 
 /* Load firmware after reset */
-extern int softing_load_fw(const char *file, struct softing *card,
-			__iomem uint8_t *virt, unsigned int size, int offset);
+int softing_load_fw(const char *file, struct softing *card,
+		    __iomem uint8_t *virt, unsigned int size, int offset);
 
 /* Load final application firmware after bootloader */
-extern int softing_load_app_fw(const char *file, struct softing *card);
+int softing_load_app_fw(const char *file, struct softing *card);
 
 /*
  * enable or disable irq
  * only called with fw.lock locked
  */
-extern int softing_enable_irq(struct softing *card, int enable);
+int softing_enable_irq(struct softing *card, int enable);
 
 /* start/stop 1 bus on card */
-extern int softing_startstop(struct net_device *netdev, int up);
+int softing_startstop(struct net_device *netdev, int up);
 
 /* netif_rx() */
-extern int softing_netdev_rx(struct net_device *netdev,
-		const struct can_frame *msg, ktime_t ktime);
+int softing_netdev_rx(struct net_device *netdev, const struct can_frame *msg,
+		      ktime_t ktime);
 
 /* SOFTING DPRAM mappings */
 #define DPRAM_RX		0x0000
-- 
1.8.1.2.459.gbcd45b4.dirty
