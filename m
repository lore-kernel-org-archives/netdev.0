From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH net-next] ravb: use pdev rather than ndev for error messages
Date: Mon,  2 Nov 2015 10:40:17 +0900
Message-ID: <1446428417-10895-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This corrects what appear to be typos, making the code consistent with
itself, and allowing meaningful prefixes to be displayed with the errors in
question.

Before:
 (null): failed to initialize MDIO
 (null): Cannot allocate desc base address table (size 176 bytes)

After:
ravb e6800000.ethernet: failed to initialize MDIO
ravb e6800000.ethernet: Cannot allocate desc base address table (size 176 bytes)

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---

Tested using an r8a7795/Salvatore-X on the topic/gen3-latest branch of
Geert Uytterhoeven's renesas-drivers tree on kernel.org: 3f5a88be9fea
("[WIP] arm64: renesas: r8a7795: Convert to new CPG/MSSR bindings")
---
 drivers/net/ethernet/renesas/ravb_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index af52c88b8b8f..2f345da1cc66 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1798,7 +1798,7 @@ static int ravb_probe(struct platform_device *pdev)
 	priv->desc_bat = dma_alloc_coherent(ndev->dev.parent, priv->desc_bat_size,
 					    &priv->desc_bat_dma, GFP_KERNEL);
 	if (!priv->desc_bat) {
-		dev_err(&ndev->dev,
+		dev_err(&pdev->dev,
 			"Cannot allocate desc base address table (size %d bytes)\n",
 			priv->desc_bat_size);
 		error = -ENOMEM;
@@ -1825,7 +1825,7 @@ static int ravb_probe(struct platform_device *pdev)
 	/* MDIO bus init */
 	error = ravb_mdio_init(priv);
 	if (error) {
-		dev_err(&ndev->dev, "failed to initialize MDIO\n");
+		dev_err(&pdev->dev, "failed to initialize MDIO\n");
 		goto out_dma_free;
 	}
 
-- 
2.1.4

