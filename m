From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 1/1] drivers: net : cpsw: Use netdev_name while requesting irq
Date: Fri, 6 Dec 2013 12:28:27 +0530
Message-ID: <1386313107-8597-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	George Cherian <george.cherian@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: George Cherian <george.cherian@ti.com>

Use netdev_name while requesting irq so that eth* name is shown
in /proc/interrupts. Previously it was showing device name as (null)
for cpsw interrupts. For using netdev_name register_netdev and then
call devm_request_irq.

Signed-off-by: George Cherian <george.cherian@ti.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index a91f0c9..61ae17f 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2090,19 +2090,6 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 	}
 
-	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
-		for (i = res->start; i <= res->end; i++) {
-			if (devm_request_irq(&pdev->dev, i, cpsw_interrupt, 0,
-					     dev_name(priv->dev), priv)) {
-				dev_err(priv->dev, "error attaching irq\n");
-				goto clean_ale_ret;
-			}
-			priv->irqs_table[k] = i;
-			priv->num_irqs = k + 1;
-		}
-		k++;
-	}
-
 	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	ndev->netdev_ops = &cpsw_netdev_ops;
@@ -2118,6 +2105,19 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 	}
 
+	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
+		for (i = res->start; i <= res->end; i++) {
+			if (devm_request_irq(&pdev->dev, i, cpsw_interrupt, 0,
+					     netdev_name(ndev), priv)) {
+				dev_err(priv->dev, "error attaching irq\n");
+				goto clean_ale_ret;
+			}
+			priv->irqs_table[k] = i;
+			priv->num_irqs = k + 1;
+		}
+		k++;
+	}
+
 	if (cpts_register(&pdev->dev, priv->cpts,
 			  data->cpts_clock_mult, data->cpts_clock_shift))
 		dev_err(priv->dev, "error registering cpts device\n");
-- 
1.8.5.rc3.2.gc302941

