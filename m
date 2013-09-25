From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/11] orinoco: Remove extern from function prototypes
Date: Wed, 25 Sep 2013 12:37:28 -0700
Message-ID: <53406cd734ec5293069acd9135440ff36a4bbdbc.1380137610.git.joe@perches.com>
References: <cover.1380137609.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380137609.git.joe@perches.com>
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
 drivers/net/wireless/orinoco/orinoco.h | 31 ++++++++++++++-----------------
 1 file changed, 14 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/orinoco/orinoco.h b/drivers/net/wireless/orinoco/orinoco.h
index 3bb936b..eebd2be 100644
--- a/drivers/net/wireless/orinoco/orinoco.h
+++ b/drivers/net/wireless/orinoco/orinoco.h
@@ -182,23 +182,20 @@ extern int orinoco_debug;
 /* Exported prototypes                                              */
 /********************************************************************/
 
-extern struct orinoco_private *alloc_orinocodev(
-	int sizeof_card, struct device *device,
-	int (*hard_reset)(struct orinoco_private *),
-	int (*stop_fw)(struct orinoco_private *, int));
-extern void free_orinocodev(struct orinoco_private *priv);
-extern int orinoco_init(struct orinoco_private *priv);
-extern int orinoco_if_add(struct orinoco_private *priv,
-			  unsigned long base_addr,
-			  unsigned int irq,
-			  const struct net_device_ops *ops);
-extern void orinoco_if_del(struct orinoco_private *priv);
-extern int orinoco_up(struct orinoco_private *priv);
-extern void orinoco_down(struct orinoco_private *priv);
-extern irqreturn_t orinoco_interrupt(int irq, void *dev_id);
-
-extern void __orinoco_ev_info(struct net_device *dev, struct hermes *hw);
-extern void __orinoco_ev_rx(struct net_device *dev, struct hermes *hw);
+struct orinoco_private *alloc_orinocodev(int sizeof_card, struct device *device,
+					 int (*hard_reset)(struct orinoco_private *),
+					 int (*stop_fw)(struct orinoco_private *, int));
+void free_orinocodev(struct orinoco_private *priv);
+int orinoco_init(struct orinoco_private *priv);
+int orinoco_if_add(struct orinoco_private *priv, unsigned long base_addr,
+		   unsigned int irq, const struct net_device_ops *ops);
+void orinoco_if_del(struct orinoco_private *priv);
+int orinoco_up(struct orinoco_private *priv);
+void orinoco_down(struct orinoco_private *priv);
+irqreturn_t orinoco_interrupt(int irq, void *dev_id);
+
+void __orinoco_ev_info(struct net_device *dev, struct hermes *hw);
+void __orinoco_ev_rx(struct net_device *dev, struct hermes *hw);
 
 int orinoco_process_xmit_skb(struct sk_buff *skb,
 			     struct net_device *dev,
-- 
1.8.1.2.459.gbcd45b4.dirty
