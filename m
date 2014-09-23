From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 4/4] net: fec: free resource after phy probe failed
Date: Tue, 23 Sep 2014 15:40:58 +0800
Message-ID: <1411458058-18934-5-git-send-email-b38611@freescale.com>
References: <1411458058-18934-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <b20596@freescale.com>,
	<b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0113.outbound.protection.outlook.com ([207.46.100.113]:3901
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753238AbaIWIJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 04:09:12 -0400
In-Reply-To: <1411458058-18934-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Free memory and disable all related clocks when there has no phy
connection or phy probe failed.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 3ce3567..2b16ead 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2675,6 +2675,8 @@ fec_enet_open(struct net_device *ndev)
 	ret = fec_enet_mii_probe(ndev);
 	if (ret) {
 		fec_enet_free_buffers(ndev);
+		fec_enet_clk_enable(ndev, false);
+		pinctrl_pm_select_sleep_state(&fep->pdev->dev);
 		return ret;
 	}
 
-- 
1.7.8
