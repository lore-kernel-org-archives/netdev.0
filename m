From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 1/2] be2net: remove unused local rsstable array
Date: Fri, 13 Nov 2015 11:36:57 +0100
Message-ID: <1447411018-11745-1-git-send-email-ivecera@redhat.com>
Cc: sriharsha.basavapatna@avagotech.com, sathya.perla@avagotech.com,
	ajit.khaparde@avagotech.com, padmanabh.ratnakar@avagotech.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46316 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932959AbbKMKhB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 05:37:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove rsstable array and its initialization from be_set_rss_hash_opts().
The array became unused after "e255787 be2net: Support for configurable
RSS hash key". The initial RSS table is now filled and stored for later
usage during Rx queue creation.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 26b6192..3d8c6c1 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -1064,9 +1064,7 @@ static int be_get_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *cmd,
 static int be_set_rss_hash_opts(struct be_adapter *adapter,
 				struct ethtool_rxnfc *cmd)
 {
-	struct be_rx_obj *rxo;
-	int status = 0, i, j;
-	u8 rsstable[128];
+	int status;
 	u32 rss_flags = adapter->rss_info.rss_flags;
 
 	if (cmd->data != L3_RSS_FLAGS &&
@@ -1115,17 +1113,7 @@ static int be_set_rss_hash_opts(struct be_adapter *adapter,
 	}
 
 	if (rss_flags == adapter->rss_info.rss_flags)
-		return status;
-
-	if (be_multi_rxq(adapter)) {
-		for (j = 0; j < 128; j += adapter->num_rss_qs) {
-			for_all_rss_queues(adapter, rxo, i) {
-				if ((j + i) >= 128)
-					break;
-				rsstable[j + i] = rxo->rss_id;
-			}
-		}
-	}
+		return 0;
 
 	status = be_cmd_rss_config(adapter, adapter->rss_info.rsstable,
 				   rss_flags, 128, adapter->rss_info.rss_hkey);
-- 
2.4.10
