From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 1/3] qede: Add support for capturing additional stats in ethtool-stats display.
Date: Tue, 16 Aug 2016 10:51:01 -0400
Message-ID: <1471359063-6193-2-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1471359063-6193-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:33888 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752510AbcHPPeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 11:34:20 -0400
In-Reply-To: <1471359063-6193-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds driver support for capturing stats ttl0_discard and
packet_too_big_discard in "ethtool -S" display.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h         | 2 ++
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 2 ++
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 2 ++
 3 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 02b06d4..9060c2a 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -36,6 +36,8 @@
 
 struct qede_stats {
 	u64 no_buff_discards;
+	u64 packet_too_big_discard;
+	u64 ttl0_discard;
 	u64 rx_ucast_bytes;
 	u64 rx_mcast_bytes;
 	u64 rx_bcast_bytes;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 0e0acfb5..93493e8 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -107,6 +107,8 @@ static const struct {
 	QEDE_PF_STAT(mftag_filter_discards),
 	QEDE_PF_STAT(mac_filter_discards),
 	QEDE_STAT(tx_err_drop_pkts),
+	QEDE_STAT(ttl0_discard),
+	QEDE_STAT(packet_too_big_discard),
 
 	QEDE_STAT(coalesced_pkts),
 	QEDE_STAT(coalesced_events),
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index e4bd02e..516f48e 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1708,6 +1708,8 @@ void qede_fill_by_demand_stats(struct qede_dev *edev)
 
 	edev->ops->get_vport_stats(edev->cdev, &stats);
 	edev->stats.no_buff_discards = stats.no_buff_discards;
+	edev->stats.packet_too_big_discard = stats.packet_too_big_discard;
+	edev->stats.ttl0_discard = stats.ttl0_discard;
 	edev->stats.rx_ucast_bytes = stats.rx_ucast_bytes;
 	edev->stats.rx_mcast_bytes = stats.rx_mcast_bytes;
 	edev->stats.rx_bcast_bytes = stats.rx_bcast_bytes;
-- 
1.8.3.1
