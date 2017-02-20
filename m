From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v3 09/12] net: ethernet: aquantia: Call netdev_register after all initialized.
Date: Mon, 20 Feb 2017 14:41:51 +0300
Message-ID: <13775c9d9cacbb20b276d350c46c74182fb92ab0.1487590641.git.pavel.belous@aquantia.com>
References: <cover.1487590641.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0086.outbound.protection.outlook.com ([104.47.42.86]:47808
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752938AbdBTLnG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 06:43:06 -0500
In-Reply-To: <cover.1487590641.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

netdev_register should be called when everything is initialized.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index a8a27c5..fdd7d72 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -261,16 +261,18 @@ int aq_nic_ndev_register(struct aq_nic_s *self)
 		ether_addr_copy(self->ndev->dev_addr, mac_addr_permanent);
 	}
 #endif
-	err = register_netdev(self->ndev);
-	if (err < 0)
-		goto err_exit;
 
-	self->is_ndev_registered = true;
 	netif_carrier_off(self->ndev);
 
 	for (i = AQ_CFG_VECS_MAX; i--;)
 		aq_nic_ndev_queue_stop(self, i);
 
+	err = register_netdev(self->ndev);
+	if (err < 0)
+		goto err_exit;
+
+	self->is_ndev_registered = true;
+
 err_exit:
 	return err;
 }
-- 
2.7.4
