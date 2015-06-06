From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH] b44: call netif_napi_del()
Date: Sat,  6 Jun 2015 23:22:46 +0200
Message-ID: <1433625766-12319-1-git-send-email-hauke@hauke-m.de>
Cc: netdev@vger.kernel.org, Hauke Mehrtens <hauke@hauke-m.de>
To: zambrano@broadcom.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hauke-m.de ([5.39.93.123]:37183 "EHLO hauke-m.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752537AbbFFVWx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Jun 2015 17:22:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the driver gets unregistered a call to netif_napi_del() was
missing.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/b44.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 77363d6..ebb9910 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2480,6 +2480,7 @@ static void b44_remove_one(struct ssb_device *sdev)
 		b44_unregister_phy_one(bp);
 	ssb_device_disable(sdev, 0);
 	ssb_bus_may_powerdown(sdev->bus);
+	netif_napi_del(&bp->napi);
 	free_netdev(dev);
 	ssb_pcihost_set_power_state(sdev, PCI_D3hot);
 	ssb_set_drvdata(sdev, NULL);
-- 
2.1.4
