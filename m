From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next 09/13] net: ethernet: aquantia: Call netdev_register after all initialized.
Date: Wed, 15 Feb 2017 23:01:17 +0300
Message-ID: <b179996dea5a6799b6e3d68536b3e3532b207d5f.1487187192.git.pavel.belous@aquantia.com>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0063.outbound.protection.outlook.com ([104.47.40.63]:44304
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751875AbdBOUDk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 15:03:40 -0500
In-Reply-To: <cover.1487187192.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

netdev_register should be called when everything is initialized.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index e50fba2..daed4c1 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -260,16 +260,18 @@ int aq_nic_ndev_register(struct aq_nic_s *self)
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
