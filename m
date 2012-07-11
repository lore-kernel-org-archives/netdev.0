From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH net-next] netxen: fix link notification order
Date: Wed, 11 Jul 2012 15:56:55 -0300
Message-ID: <1342033015-31442-1-git-send-email-fbl@redhat.com>
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2674 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751593Ab2GKS5I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 14:57:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First update the adapter variables with the current speed and
mode before fire the notification. Otherwise, the get_settings()
may provide old values.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index b2c1b676..bc165f4 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -1437,8 +1437,6 @@ netxen_handle_linkevent(struct netxen_adapter *adapter, nx_fw_msg_t *msg)
 				netdev->name, cable_len);
 	}
 
-	netxen_advert_link_change(adapter, link_status);
-
 	/* update link parameters */
 	if (duplex == LINKEVENT_FULL_DUPLEX)
 		adapter->link_duplex = DUPLEX_FULL;
@@ -1447,6 +1445,8 @@ netxen_handle_linkevent(struct netxen_adapter *adapter, nx_fw_msg_t *msg)
 	adapter->module_type = module;
 	adapter->link_autoneg = autoneg;
 	adapter->link_speed = link_speed;
+
+	netxen_advert_link_change(adapter, link_status);
 }
 
 static void
-- 
1.7.10.4
