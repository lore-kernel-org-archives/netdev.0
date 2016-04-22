From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next v2 1/4] qed*: Align statistics names
Date: Fri, 22 Apr 2016 08:41:01 +0300
Message-ID: <1461303664-15961-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1461303664-15961-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:54027 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753639AbcDVFlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 01:41:12 -0400
In-Reply-To: <1461303664-15961-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a difference in statsitics' names starting at qed and
propagating to qede, where egress counters indicate ranges while ingress
counters indiciate high-end.
Align all statistcs to follow the same conventions - name indicates range.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c        | 20 ++++++++---------
 drivers/net/ethernet/qlogic/qede/qede.h         | 20 ++++++++---------
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 20 ++++++++---------
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 29 ++++++++++++++++---------
 include/linux/qed/qed_if.h                      | 20 ++++++++---------
 5 files changed, 59 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index fb5f3b8..31e1d51 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -1415,16 +1415,16 @@ static void __qed_get_vport_port_stats(struct qed_hwfn *p_hwfn,
 			sizeof(port_stats));
 
 	p_stats->rx_64_byte_packets		+= port_stats.pmm.r64;
-	p_stats->rx_127_byte_packets		+= port_stats.pmm.r127;
-	p_stats->rx_255_byte_packets		+= port_stats.pmm.r255;
-	p_stats->rx_511_byte_packets		+= port_stats.pmm.r511;
-	p_stats->rx_1023_byte_packets		+= port_stats.pmm.r1023;
-	p_stats->rx_1518_byte_packets		+= port_stats.pmm.r1518;
-	p_stats->rx_1522_byte_packets		+= port_stats.pmm.r1522;
-	p_stats->rx_2047_byte_packets		+= port_stats.pmm.r2047;
-	p_stats->rx_4095_byte_packets		+= port_stats.pmm.r4095;
-	p_stats->rx_9216_byte_packets		+= port_stats.pmm.r9216;
-	p_stats->rx_16383_byte_packets		+= port_stats.pmm.r16383;
+	p_stats->rx_65_to_127_byte_packets	+= port_stats.pmm.r127;
+	p_stats->rx_128_to_255_byte_packets	+= port_stats.pmm.r255;
+	p_stats->rx_256_to_511_byte_packets	+= port_stats.pmm.r511;
+	p_stats->rx_512_to_1023_byte_packets	+= port_stats.pmm.r1023;
+	p_stats->rx_1024_to_1518_byte_packets	+= port_stats.pmm.r1518;
+	p_stats->rx_1519_to_1522_byte_packets	+= port_stats.pmm.r1522;
+	p_stats->rx_1519_to_2047_byte_packets	+= port_stats.pmm.r2047;
+	p_stats->rx_2048_to_4095_byte_packets	+= port_stats.pmm.r4095;
+	p_stats->rx_4096_to_9216_byte_packets	+= port_stats.pmm.r9216;
+	p_stats->rx_9217_to_16383_byte_packets	+= port_stats.pmm.r16383;
 	p_stats->rx_crc_errors			+= port_stats.pmm.rfcs;
 	p_stats->rx_mac_crtl_frames		+= port_stats.pmm.rxcf;
 	p_stats->rx_pause_frames		+= port_stats.pmm.rxpf;
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 16df159..a687e7a 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -59,16 +59,16 @@ struct qede_stats {
 
 	/* port */
 	u64 rx_64_byte_packets;
-	u64 rx_127_byte_packets;
-	u64 rx_255_byte_packets;
-	u64 rx_511_byte_packets;
-	u64 rx_1023_byte_packets;
-	u64 rx_1518_byte_packets;
-	u64 rx_1522_byte_packets;
-	u64 rx_2047_byte_packets;
-	u64 rx_4095_byte_packets;
-	u64 rx_9216_byte_packets;
-	u64 rx_16383_byte_packets;
+	u64 rx_65_to_127_byte_packets;
+	u64 rx_128_to_255_byte_packets;
+	u64 rx_256_to_511_byte_packets;
+	u64 rx_512_to_1023_byte_packets;
+	u64 rx_1024_to_1518_byte_packets;
+	u64 rx_1519_to_1522_byte_packets;
+	u64 rx_1519_to_2047_byte_packets;
+	u64 rx_2048_to_4095_byte_packets;
+	u64 rx_4096_to_9216_byte_packets;
+	u64 rx_9217_to_16383_byte_packets;
 	u64 rx_crc_errors;
 	u64 rx_mac_crtl_frames;
 	u64 rx_pause_frames;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index f0982f1..f87e83b 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -59,16 +59,16 @@ static const struct {
 	QEDE_STAT(tx_bcast_pkts),
 
 	QEDE_PF_STAT(rx_64_byte_packets),
-	QEDE_PF_STAT(rx_127_byte_packets),
-	QEDE_PF_STAT(rx_255_byte_packets),
-	QEDE_PF_STAT(rx_511_byte_packets),
-	QEDE_PF_STAT(rx_1023_byte_packets),
-	QEDE_PF_STAT(rx_1518_byte_packets),
-	QEDE_PF_STAT(rx_1522_byte_packets),
-	QEDE_PF_STAT(rx_2047_byte_packets),
-	QEDE_PF_STAT(rx_4095_byte_packets),
-	QEDE_PF_STAT(rx_9216_byte_packets),
-	QEDE_PF_STAT(rx_16383_byte_packets),
+	QEDE_PF_STAT(rx_65_to_127_byte_packets),
+	QEDE_PF_STAT(rx_128_to_255_byte_packets),
+	QEDE_PF_STAT(rx_256_to_511_byte_packets),
+	QEDE_PF_STAT(rx_512_to_1023_byte_packets),
+	QEDE_PF_STAT(rx_1024_to_1518_byte_packets),
+	QEDE_PF_STAT(rx_1519_to_1522_byte_packets),
+	QEDE_PF_STAT(rx_1519_to_2047_byte_packets),
+	QEDE_PF_STAT(rx_2048_to_4095_byte_packets),
+	QEDE_PF_STAT(rx_4096_to_9216_byte_packets),
+	QEDE_PF_STAT(rx_9217_to_16383_byte_packets),
 	QEDE_PF_STAT(tx_64_byte_packets),
 	QEDE_PF_STAT(tx_65_to_127_byte_packets),
 	QEDE_PF_STAT(tx_128_to_255_byte_packets),
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index e5dc35a..3cdfc7d 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1575,16 +1575,25 @@ void qede_fill_by_demand_stats(struct qede_dev *edev)
 	edev->stats.coalesced_bytes = stats.tpa_coalesced_bytes;
 
 	edev->stats.rx_64_byte_packets = stats.rx_64_byte_packets;
-	edev->stats.rx_127_byte_packets = stats.rx_127_byte_packets;
-	edev->stats.rx_255_byte_packets = stats.rx_255_byte_packets;
-	edev->stats.rx_511_byte_packets = stats.rx_511_byte_packets;
-	edev->stats.rx_1023_byte_packets = stats.rx_1023_byte_packets;
-	edev->stats.rx_1518_byte_packets = stats.rx_1518_byte_packets;
-	edev->stats.rx_1522_byte_packets = stats.rx_1522_byte_packets;
-	edev->stats.rx_2047_byte_packets = stats.rx_2047_byte_packets;
-	edev->stats.rx_4095_byte_packets = stats.rx_4095_byte_packets;
-	edev->stats.rx_9216_byte_packets = stats.rx_9216_byte_packets;
-	edev->stats.rx_16383_byte_packets = stats.rx_16383_byte_packets;
+	edev->stats.rx_65_to_127_byte_packets = stats.rx_65_to_127_byte_packets;
+	edev->stats.rx_128_to_255_byte_packets =
+				stats.rx_128_to_255_byte_packets;
+	edev->stats.rx_256_to_511_byte_packets =
+				stats.rx_256_to_511_byte_packets;
+	edev->stats.rx_512_to_1023_byte_packets =
+				stats.rx_512_to_1023_byte_packets;
+	edev->stats.rx_1024_to_1518_byte_packets =
+				stats.rx_1024_to_1518_byte_packets;
+	edev->stats.rx_1519_to_1522_byte_packets =
+				stats.rx_1519_to_1522_byte_packets;
+	edev->stats.rx_1519_to_2047_byte_packets =
+				stats.rx_1519_to_2047_byte_packets;
+	edev->stats.rx_2048_to_4095_byte_packets =
+				stats.rx_2048_to_4095_byte_packets;
+	edev->stats.rx_4096_to_9216_byte_packets =
+				stats.rx_4096_to_9216_byte_packets;
+	edev->stats.rx_9217_to_16383_byte_packets =
+				stats.rx_9217_to_16383_byte_packets;
 	edev->stats.rx_crc_errors = stats.rx_crc_errors;
 	edev->stats.rx_mac_crtl_frames = stats.rx_mac_crtl_frames;
 	edev->stats.rx_pause_frames = stats.rx_pause_frames;
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 67e8c20..82a7fe0 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -384,16 +384,16 @@ struct qed_eth_stats {
 
 	/* port */
 	u64	rx_64_byte_packets;
-	u64	rx_127_byte_packets;
-	u64	rx_255_byte_packets;
-	u64	rx_511_byte_packets;
-	u64	rx_1023_byte_packets;
-	u64	rx_1518_byte_packets;
-	u64	rx_1522_byte_packets;
-	u64	rx_2047_byte_packets;
-	u64	rx_4095_byte_packets;
-	u64	rx_9216_byte_packets;
-	u64	rx_16383_byte_packets;
+	u64	rx_65_to_127_byte_packets;
+	u64	rx_128_to_255_byte_packets;
+	u64	rx_256_to_511_byte_packets;
+	u64	rx_512_to_1023_byte_packets;
+	u64	rx_1024_to_1518_byte_packets;
+	u64	rx_1519_to_1522_byte_packets;
+	u64	rx_1519_to_2047_byte_packets;
+	u64	rx_2048_to_4095_byte_packets;
+	u64	rx_4096_to_9216_byte_packets;
+	u64	rx_9217_to_16383_byte_packets;
 	u64	rx_crc_errors;
 	u64	rx_mac_crtl_frames;
 	u64	rx_pause_frames;
-- 
1.9.3
