From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v2 06/12] net: ethernet: aquantia: Fixed missing rtnl_unlock.
Date: Sat, 18 Feb 2017 00:07:28 +0300
Message-ID: <80a3455a5e65f5eb911d4863ffb3b7cd1d0b26bf.1487365317.git.pavel.belous@aquantia.com>
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
Received: from mail-sn1nam01on0077.outbound.protection.outlook.com ([104.47.32.77]:52345
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S935081AbdBQVJP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 16:09:15 -0500
In-Reply-To: <cover.1487365317.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

rtnl_unlock should be called if error occurred.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index a153750..1bf5975 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -931,7 +931,7 @@ int aq_nic_change_pm_state(struct aq_nic_s *self, pm_message_t *pm_msg)
 
 	if (!netif_running(self->ndev)) {
 		err = 0;
-		goto err_exit;
+		goto out;
 	}
 	rtnl_lock();
 	if (pm_msg->event & PM_EVENT_SLEEP || pm_msg->event & PM_EVENT_FREEZE) {
@@ -956,8 +956,9 @@ int aq_nic_change_pm_state(struct aq_nic_s *self, pm_message_t *pm_msg)
 		netif_device_attach(self->ndev);
 		netif_tx_start_all_queues(self->ndev);
 	}
-	rtnl_unlock();
 
 err_exit:
+	rtnl_unlock();
+out:
 	return err;
 }
-- 
2.7.4
