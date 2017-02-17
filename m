From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v2 09/12] net: ethernet: aquantia: Call netdev_register after all initialized.
Date: Sat, 18 Feb 2017 00:07:31 +0300
Message-ID: <4c1f4507fcb3df92e2ea81843870c4a620e59181.1487365317.git.pavel.belous@aquantia.com>
References: <cover.1487365317.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0072.outbound.protection.outlook.com ([104.47.32.72]:2114
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S935044AbdBQVJZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 16:09:25 -0500
In-Reply-To: <cover.1487365317.git.pavel.belous@aquantia.com>
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
