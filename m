From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v4 06/12] net: ethernet: aquantia: Fixed missing rtnl_unlock.
Date: Mon, 20 Feb 2017 22:36:44 +0300
Message-ID: <894f21bfee34a1e15c462efb56ccf323cbd1c504.1487618263.git.pavel.belous@aquantia.com>
References: <cover.1487618263.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0068.outbound.protection.outlook.com ([104.47.38.68]:52795
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751478AbdBTTh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 14:37:58 -0500
In-Reply-To: <cover.1487618263.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

rtnl_unlock should be called if error occurred.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index 4b8d074..646314c 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -932,7 +932,7 @@ int aq_nic_change_pm_state(struct aq_nic_s *self, pm_message_t *pm_msg)
 
 	if (!netif_running(self->ndev)) {
 		err = 0;
-		goto err_exit;
+		goto out;
 	}
 	rtnl_lock();
 	if (pm_msg->event & PM_EVENT_SLEEP || pm_msg->event & PM_EVENT_FREEZE) {
@@ -957,8 +957,9 @@ int aq_nic_change_pm_state(struct aq_nic_s *self, pm_message_t *pm_msg)
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
