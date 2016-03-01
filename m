From: Wolfram Sang <wsa@the-dreams.de>
Subject: [PATCH 2/2] net: ethernet: renesas: sh_eth: don't open code of_device_get_match_data()
Date: Tue,  1 Mar 2016 17:37:59 +0100
Message-ID: <1456850284-8336-2-git-send-email-wsa@the-dreams.de>
References: <1456850284-8336-1-git-send-email-wsa@the-dreams.de>
Cc: Wolfram Sang <wsa@the-dreams.de>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
To: linux-renesas-soc@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1456850284-8336-1-git-send-email-wsa@the-dreams.de>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfram Sang <wsa+renesas@sang-engineering.com>

This change will also make Coverity happy by avoiding a theoretical NULL
pointer dereference; yet another reason is to use the above helper function
to tighten the code and make it more readable.

Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>
---

Tested on a Lager board.

 drivers/net/ethernet/renesas/sh_eth.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 0a150b2289146f..8b6c07fe3d407d 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -3056,15 +3056,11 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	mdp->ether_link_active_low = pd->ether_link_active_low;
 
 	/* set cpu data */
-	if (id) {
+	if (id)
 		mdp->cd = (struct sh_eth_cpu_data *)id->driver_data;
-	} else	{
-		const struct of_device_id *match;
+	else
+		mdp->cd = (struct sh_eth_cpu_data *)of_device_get_match_data(&pdev->dev);
 
-		match = of_match_device(of_match_ptr(sh_eth_match_table),
-					&pdev->dev);
-		mdp->cd = (struct sh_eth_cpu_data *)match->data;
-	}
 	mdp->reg_offset = sh_eth_get_register_offset(mdp->cd->register_type);
 	if (!mdp->reg_offset) {
 		dev_err(&pdev->dev, "Unknown register type (%d)\n",
-- 
2.7.0
