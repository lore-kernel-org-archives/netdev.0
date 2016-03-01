From: Wolfram Sang <wsa@the-dreams.de>
Subject: [PATCH 1/2] net: ethernet: renesas: ravb_main: don't open code of_device_get_match_data()
Date: Tue,  1 Mar 2016 17:37:58 +0100
Message-ID: <1456850284-8336-1-git-send-email-wsa@the-dreams.de>
Cc: Wolfram Sang <wsa@the-dreams.de>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
To: linux-renesas-soc@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfram Sang <wsa+renesas@sang-engineering.com>

This change will also make Coverity happy by avoiding a theoretical NULL
pointer dereference; yet another reason is to use the above helper function
to tighten the code and make it more readable.

Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>
---

Compile tested only. I am on the road and don't have acces to my Gen3 board.
If someone could test it, that would be much appreciated. Or I'll do it next
week. The pattern worked for other drivers I could actually test, though.

 drivers/net/ethernet/renesas/ravb_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index c936682aae68df..b8613a611a6278 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1706,7 +1706,6 @@ static int ravb_set_gti(struct net_device *ndev)
 static int ravb_probe(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
-	const struct of_device_id *match;
 	struct ravb_private *priv;
 	enum ravb_chip_id chip_id;
 	struct net_device *ndev;
@@ -1738,8 +1737,7 @@ static int ravb_probe(struct platform_device *pdev)
 	ndev->base_addr = res->start;
 	ndev->dma = -1;
 
-	match = of_match_device(of_match_ptr(ravb_match_table), &pdev->dev);
-	chip_id = (enum ravb_chip_id)match->data;
+	chip_id = (enum ravb_chip_id)of_device_get_match_data(&pdev->dev);
 
 	if (chip_id == RCAR_GEN3)
 		irq = platform_get_irq_byname(pdev, "ch22");
-- 
2.7.0
