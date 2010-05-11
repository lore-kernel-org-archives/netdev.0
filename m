From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 3/3] cxgb4: report GRO stats with ethtool -S
Date: Mon, 10 May 2010 18:58:09 -0700
Message-ID: <1273543089-10938-3-git-send-email-dm@chelsio.com>
References: <1273543089-10938-1-git-send-email-dm@chelsio.com>
 <1273543089-10938-2-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14560 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932161Ab0EKB6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 21:58:11 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o4B1wBcv007197
	for <netdev@vger.kernel.org>; Mon, 10 May 2010 18:58:11 -0700
In-Reply-To: <1273543089-10938-2-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 80c3fc5..90d375b 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -859,6 +859,8 @@ static char stats_strings[][ETH_GSTRING_LEN] = {
 	"RxCsumGood         ",
 	"VLANextractions    ",
 	"VLANinsertions     ",
+	"GROpackets         ",
+	"GROmerged          ",
 };
 
 static int get_sset_count(struct net_device *dev, int sset)
@@ -922,6 +924,8 @@ struct queue_port_stats {
 	u64 rx_csum;
 	u64 vlan_ex;
 	u64 vlan_ins;
+	u64 gro_pkts;
+	u64 gro_merged;
 };
 
 static void collect_sge_port_stats(const struct adapter *adap,
@@ -938,6 +942,8 @@ static void collect_sge_port_stats(const struct adapter *adap,
 		s->rx_csum += rx->stats.rx_cso;
 		s->vlan_ex += rx->stats.vlan_ex;
 		s->vlan_ins += tx->vlan_ins;
+		s->gro_pkts += rx->stats.lro_pkts;
+		s->gro_merged += rx->stats.lro_merged;
 	}
 }
 
-- 
1.5.4

