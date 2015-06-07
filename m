From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v2] b44: call netif_napi_del()
Date: Sun,  7 Jun 2015 14:11:48 +0200
Message-ID: <1433679108-20923-1-git-send-email-hauke@hauke-m.de>
Cc: netdev@vger.kernel.org, Hauke Mehrtens <hauke@hauke-m.de>
To: zambrano@broadcom.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hauke-m.de ([5.39.93.123]:37318 "EHLO hauke-m.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752766AbbFGML5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Jun 2015 08:11:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the driver gets unregistered a call to netif_napi_del() was
missing, this all was also missing in the error paths of
b44_init_one().

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---

changes since v1:
 * netif_napi_del() is now also called in b44_init_one() error paths.

 drivers/net/ethernet/broadcom/b44.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 77363d6..a3b1c07 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2464,6 +2464,7 @@ err_out_powerdown:
 	ssb_bus_may_powerdown(sdev->bus);
 
 err_out_free_dev:
+	netif_napi_del(&bp->napi);
 	free_netdev(dev);
 
 out:
@@ -2480,6 +2481,7 @@ static void b44_remove_one(struct ssb_device *sdev)
 		b44_unregister_phy_one(bp);
 	ssb_device_disable(sdev, 0);
 	ssb_bus_may_powerdown(sdev->bus);
+	netif_napi_del(&bp->napi);
 	free_netdev(dev);
 	ssb_pcihost_set_power_state(sdev, PCI_D3hot);
 	ssb_set_drvdata(sdev, NULL);
-- 
2.1.4
