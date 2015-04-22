From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next] be2net: log link status
Date: Wed, 22 Apr 2015 14:56:10 +0200
Message-ID: <1429707370-2792-1-git-send-email-ivecera@redhat.com>
Cc: Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51792 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752800AbbDVM4N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2015 08:56:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver unlike other drivers does not log link state changes.

Cc: Sathya Perla <sathya.perla@emulex.com>
Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index fb0bc3c..e349131 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -662,6 +662,8 @@ void be_link_status_update(struct be_adapter *adapter, u8 link_status)
 		netif_carrier_on(netdev);
 	else
 		netif_carrier_off(netdev);
+
+	netdev_info(netdev, "Link is %s\n", link_status ? "Up" : "Down");
 }
 
 static void be_tx_stats_update(struct be_tx_obj *txo, struct sk_buff *skb)
-- 
2.0.5
