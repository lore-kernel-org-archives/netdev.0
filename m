From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: replace devm_kzalloc() with devm_kmalloc()
Date: Mon, 12 May 2014 00:05:50 +0400
Message-ID: <201405120005.51199.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When I was converting the driver to the managed device API, only devm_kzalloc()
was available for memory allocation, so I had to use it, despite zeroing out
PHY IRQ array right before initializing all its entries with PHY_POLL was quite
stupid. Now that devm_kmalloc() has become available, we can avoid the needless
zeroing out of the PHY IRQ array.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is against DaveM's 'net-next.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -2627,7 +2627,7 @@ static int sh_mdio_init(struct sh_eth_pr
 		 pdev->name, pdev->id);
 
 	/* PHY IRQ */
-	mdp->mii_bus->irq = devm_kzalloc(dev, sizeof(int) * PHY_MAX_ADDR,
+	mdp->mii_bus->irq = devm_kmalloc(dev, sizeof(int) * PHY_MAX_ADDR,
 					 GFP_KERNEL);
 	if (!mdp->mii_bus->irq) {
 		ret = -ENOMEM;
