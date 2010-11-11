From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-next-26 2/5] cxgb4vf: add ethtool statistics for GRO.
Date: Thu, 11 Nov 2010 11:30:41 -0800
Message-ID: <1289503844-18059-3-git-send-email-leedom@chelsio.com>
References: <1289503844-18059-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28774 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754822Ab0KKTav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 14:30:51 -0500
In-Reply-To: <1289503844-18059-1-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ethtool statistics for GRO.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 6235719..47417d4 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -1346,6 +1346,8 @@ struct queue_port_stats {
 	u64 rx_csum;
 	u64 vlan_ex;
 	u64 vlan_ins;
+	u64 lro_pkts;
+	u64 lro_merged;
 };
 
 /*
@@ -1383,6 +1385,8 @@ static const char stats_strings[][ETH_GSTRING_LEN] = {
 	"RxCsumGood        ",
 	"VLANextractions   ",
 	"VLANinsertions    ",
+	"GROPackets        ",
+	"GROMerged         ",
 };
 
 /*
@@ -1432,6 +1436,8 @@ static void collect_sge_port_stats(const struct adapter *adapter,
 		stats->rx_csum += rxq->stats.rx_cso;
 		stats->vlan_ex += rxq->stats.vlan_ex;
 		stats->vlan_ins += txq->vlan_ins;
+		stats->lro_pkts += rxq->stats.lro_pkts;
+		stats->lro_merged += rxq->stats.lro_merged;
 	}
 }
 
-- 
1.7.0.4

