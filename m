From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH next 2/3] be2net: Display RoCE specific counters in ethtool -S
Date: Thu, 3 Oct 2013 16:16:50 -0500
Message-ID: <20131003211650.GA3460@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:58129 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755663Ab3JCVQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 17:16:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SkyHawk-R can support RoCE. Add code to display RoCE specific
counters maintained in hardware.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         | 5 +++++
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 7 ++++++-
 drivers/net/ethernet/emulex/benet/be_main.c    | 8 ++++++++
 3 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index add6d7a..944e6be 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -325,6 +325,11 @@ struct be_drv_stats {
 	u32 rx_input_fifo_overflow_drop;
 	u32 pmem_fifo_overflow_drop;
 	u32 jabber_events;
+	u32 rx_roce_bytes_lsd;
+	u32 rx_roce_bytes_msd;
+	u32 rx_roce_frames;
+	u32 roce_drops_payload_len;
+	u32 roce_drops_crc;
 };
 
 struct be_vf_cfg {
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 3dcf817..0833003 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -116,7 +116,12 @@ static const struct be_ethtool_stat et_stats[] = {
 	{DRVSTAT_INFO(rx_drops_mtu)},
 	/* Number of packets dropped due to random early drop function */
 	{DRVSTAT_INFO(eth_red_drops)},
-	{DRVSTAT_INFO(be_on_die_temperature)}
+	{DRVSTAT_INFO(be_on_die_temperature)},
+	{DRVSTAT_INFO(rx_roce_bytes_lsd)},
+	{DRVSTAT_INFO(rx_roce_bytes_msd)},
+	{DRVSTAT_INFO(rx_roce_frames)},
+	{DRVSTAT_INFO(roce_drops_payload_len)},
+	{DRVSTAT_INFO(roce_drops_crc)}
 };
 #define ETHTOOL_STATS_NUM ARRAY_SIZE(et_stats)
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6e3a141..2d6115c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -474,6 +474,14 @@ static void populate_be_v2_stats(struct be_adapter *adapter)
 	drvs->rx_drops_no_tpre_descr = rxf_stats->rx_drops_no_tpre_descr;
 	drvs->rx_drops_too_many_frags = rxf_stats->rx_drops_too_many_frags;
 	adapter->drv_stats.eth_red_drops = pmem_sts->eth_red_drops;
+	if (be_roce_supported(adapter))  {
+		drvs->rx_roce_bytes_lsd = port_stats->roce_bytes_received_lsd;
+		drvs->rx_roce_bytes_msd = port_stats->roce_bytes_received_msd;
+		drvs->rx_roce_frames = port_stats->roce_frames_received;
+		drvs->roce_drops_crc = port_stats->roce_drops_crc;
+		drvs->roce_drops_payload_len =
+			port_stats->roce_drops_payload_len;
+	}
 }
 
 static void populate_lancer_stats(struct be_adapter *adapter)
-- 
1.8.1.2
