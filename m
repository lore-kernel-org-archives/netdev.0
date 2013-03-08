From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 4/5] qlcnic: Fix ethtool statistics collection
Date: Fri,  8 Mar 2013 14:53:52 -0500
Message-ID: <1362772433-12045-5-git-send-email-shahed.shaikh@qlogic.com>
References: <1362772433-12045-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:50417 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751264Ab3CHURL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 15:17:11 -0500
In-Reply-To: <1362772433-12045-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

o Properly fill statistics data into buffer.
  Update buffer pointer properly after filling statistics data into buffer.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index f687a63..f4f279d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1071,8 +1071,7 @@ qlcnic_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 	}
 }
 
-static void
-qlcnic_fill_stats(u64 *data, void *stats, int type)
+static u64 *qlcnic_fill_stats(u64 *data, void *stats, int type)
 {
 	if (type == QLCNIC_MAC_STATS) {
 		struct qlcnic_mac_statistics *mac_stats =
@@ -1121,6 +1120,7 @@ qlcnic_fill_stats(u64 *data, void *stats, int type)
 		*data++ = QLCNIC_FILL_STATS(esw_stats->local_frames);
 		*data++ = QLCNIC_FILL_STATS(esw_stats->numbytes);
 	}
+	return data;
 }
 
 static void qlcnic_get_ethtool_stats(struct net_device *dev,
@@ -1148,7 +1148,7 @@ static void qlcnic_get_ethtool_stats(struct net_device *dev,
 		/* Retrieve MAC statistics from firmware */
 		memset(&mac_stats, 0, sizeof(struct qlcnic_mac_statistics));
 		qlcnic_get_mac_stats(adapter, &mac_stats);
-		qlcnic_fill_stats(data, &mac_stats, QLCNIC_MAC_STATS);
+		data = qlcnic_fill_stats(data, &mac_stats, QLCNIC_MAC_STATS);
 	}
 
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
@@ -1160,7 +1160,7 @@ static void qlcnic_get_ethtool_stats(struct net_device *dev,
 	if (ret)
 		return;
 
-	qlcnic_fill_stats(data, &port_stats.rx, QLCNIC_ESW_STATS);
+	data = qlcnic_fill_stats(data, &port_stats.rx, QLCNIC_ESW_STATS);
 	ret = qlcnic_get_port_stats(adapter, adapter->ahw->pci_func,
 			QLCNIC_QUERY_TX_COUNTER, &port_stats.tx);
 	if (ret)
-- 
1.5.6
