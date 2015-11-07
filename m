From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] dwc_eth_qos: Delete an unnecessary check before the function
 call "of_node_put"
Date: Sat, 7 Nov 2015 16:34:48 +0100
Message-ID: <563E1A18.101@users.sourceforge.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net> <563C5392.6030309@users.sourceforge.net>
 <20151106.233311.2260896695923603885.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: David Miller <davem@davemloft.net>,
	Lars Persson <lars.persson@axis.com>, netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20151106.233311.2260896695923603885.davem@davemloft.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 7 Nov 2015 16:30:34 +0100

The of_node_put() function tests whether its argument is NULL
and then returns immediately.
Thus the test around the call is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 85b3326..9066d7a 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -2970,8 +2970,7 @@ err_out_unregister_netdev:
 err_out_clk_dis_aper:
 	clk_disable_unprepare(lp->apb_pclk);
 err_out_free_netdev:
-	if (lp->phy_node)
-		of_node_put(lp->phy_node);
+	of_node_put(lp->phy_node);
 	free_netdev(ndev);
 	platform_set_drvdata(pdev, NULL);
 	return ret;
-- 
2.6.2

