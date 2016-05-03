From: Matthias Brugger <mbrugger@suse.com>
Subject: [PATCH] drivers: net: xgene: Fix error handling
Date: Tue,  3 May 2016 16:05:07 +0200
Message-ID: <1462284307-15401-1-git-send-email-mbrugger@suse.com>
Cc: kchudgar@apm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Matthias Brugger <mbrugger@suse.com>
To: davem@davemloft.net, isubramanian@apm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When probe bails out with an error, we try to unregister the
netdev before we have even registered it. Fix the goto statements
for that.

Signed-off-by: Matthias Brugger <mbrugger@suse.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 8d4c1ad..99d7e58 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1595,21 +1595,22 @@ static int xgene_enet_probe(struct platform_device *pdev)
 
 	ret = xgene_enet_init_hw(pdata);
 	if (ret)
-		goto err;
+		goto err_netdev;
 
 	mac_ops = pdata->mac_ops;
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
 		ret = xgene_enet_mdio_config(pdata);
 		if (ret)
-			goto err;
+			goto err_netdev;
 	} else {
 		INIT_DELAYED_WORK(&pdata->link_work, mac_ops->link_state);
 	}
 
 	xgene_enet_napi_add(pdata);
 	return 0;
-err:
+err_netdev:
 	unregister_netdev(ndev);
+err:
 	free_netdev(ndev);
 	return ret;
 }
-- 
2.6.6
