From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH] be2net: netpoll support
Date: Thu,  8 Dec 2011 12:31:21 +0100
Message-ID: <1323343881-7864-1-git-send-email-ivecera@redhat.com>
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39884 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750715Ab1LHLbZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 06:31:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing netpoll support.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 7236280..3854fb0 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2666,6 +2666,19 @@ err:
 	return status;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void be_netpoll(struct net_device *netdev)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	struct be_rx_obj *rxo;
+	int i;
+
+	event_handle(adapter, &adapter->tx_eq, false);
+	for_all_rx_queues(adapter, rxo, i)
+		event_handle(adapter, &rxo->rx_eq, true);
+}
+#endif
+
 #define FW_FILE_HDR_SIGN 	"ServerEngines Corp. "
 static bool be_flash_redboot(struct be_adapter *adapter,
 			const u8 *p, u32 img_start, int image_size,
@@ -3014,7 +3027,10 @@ static struct net_device_ops be_netdev_ops = {
 	.ndo_set_vf_mac		= be_set_vf_mac,
 	.ndo_set_vf_vlan	= be_set_vf_vlan,
 	.ndo_set_vf_tx_rate	= be_set_vf_tx_rate,
-	.ndo_get_vf_config	= be_get_vf_config
+	.ndo_get_vf_config	= be_get_vf_config,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= be_netpoll,
+#endif
 };
 
 static void be_netdev_init(struct net_device *netdev)
-- 
1.7.3.4
