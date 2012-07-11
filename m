From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 4/9] qlge: Clean up ethtool set WOL routine.
Date: Tue, 10 Jul 2012 20:57:34 -0400
Message-ID: <1341968259-18931-5-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1341968259-18931-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:52155 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753122Ab2GKBOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 21:14:37 -0400
In-Reply-To: <1341968259-18931-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
index c2adfa2..3b0912f 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
@@ -401,7 +401,6 @@ static void ql_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 static int ql_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
-	int status;
 	unsigned short ssys_dev = qdev->pdev->subsystem_device;
 
 	/* WOL is only supported for mezz card. */
@@ -416,14 +415,6 @@ static int ql_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 	qdev->wol = wol->wolopts;
 
 	netif_info(qdev, drv, qdev->ndev, "Set wol option 0x%x\n", qdev->wol);
-	if (!qdev->wol) {
-		u32 wol = 0;
-		status = ql_mb_wol_mode(qdev, wol);
-		netif_err(qdev, drv, qdev->ndev, "WOL %s (wol code 0x%x)\n",
-			  status == 0 ? "cleared successfully" : "clear failed",
-			  wol);
-	}
-
 	return 0;
 }
 
-- 
1.7.1
