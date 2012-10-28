From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/16] ethernet: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
Date: Sun, 28 Oct 2012 01:05:48 -0700
Message-ID: <78c3d489101b08588cb067181171eb070bdac756.1351411047.git.joe@perches.com>
References: <cover.1351411047.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1351411047.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev_<level> calls take less code than dev_printk(KERN_<LEVEL>
and reducing object size is good.
Coalesce formats for easier grep.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/chelsio/cxgb3/common.h |    7 +++----
 drivers/net/ethernet/marvell/pxa168_eth.c   |    7 +++----
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/common.h b/drivers/net/ethernet/chelsio/cxgb3/common.h
index df01b63..8c82248 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/common.h
+++ b/drivers/net/ethernet/chelsio/cxgb3/common.h
@@ -42,10 +42,9 @@
 #include <linux/mdio.h>
 #include "version.h"
 
-#define CH_ERR(adap, fmt, ...)   dev_err(&adap->pdev->dev, fmt, ## __VA_ARGS__)
-#define CH_WARN(adap, fmt, ...)  dev_warn(&adap->pdev->dev, fmt, ## __VA_ARGS__)
-#define CH_ALERT(adap, fmt, ...) \
-	dev_printk(KERN_ALERT, &adap->pdev->dev, fmt, ## __VA_ARGS__)
+#define CH_ERR(adap, fmt, ...)   dev_err(&adap->pdev->dev, fmt, ##__VA_ARGS__)
+#define CH_WARN(adap, fmt, ...)  dev_warn(&adap->pdev->dev, fmt, ##__VA_ARGS__)
+#define CH_ALERT(adap, fmt, ...) dev_alert(&adap->pdev->dev, fmt, ##__VA_ARGS__)
 
 /*
  * More powerful macro that selectively prints messages based on msg_enable.
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 5948972..10d678d 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1131,7 +1131,7 @@ static int pxa168_eth_open(struct net_device *dev)
 	err = request_irq(dev->irq, pxa168_eth_int_handler,
 			  IRQF_DISABLED, dev->name, dev);
 	if (err) {
-		dev_printk(KERN_ERR, &dev->dev, "can't assign irq\n");
+		dev_err(&dev->dev, "can't assign irq\n");
 		return -EAGAIN;
 	}
 	pep->rx_resource_err = 0;
@@ -1201,9 +1201,8 @@ static int pxa168_eth_change_mtu(struct net_device *dev, int mtu)
 	 */
 	pxa168_eth_stop(dev);
 	if (pxa168_eth_open(dev)) {
-		dev_printk(KERN_ERR, &dev->dev,
-			   "fatal error on re-opening device after "
-			   "MTU change\n");
+		dev_err(&dev->dev,
+			"fatal error on re-opening device after MTU change\n");
 	}
 
 	return 0;
-- 
1.7.8.112.g3fd21
