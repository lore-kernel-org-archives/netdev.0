From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 09/12] qlcnic: fix endiness in eswitch statistics
Date: Thu, 19 Aug 2010 08:08:30 -0700
Message-ID: <1282230513-25286-10-git-send-email-amit.salecha@qlogic.com>
References: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:53451 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753926Ab0HSPIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 11:08:35 -0400
In-Reply-To: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ctx.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 74ae3b0..315705b 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -946,6 +946,7 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 		const u8 rx_tx, struct __qlcnic_esw_statistics *esw_stats) {
 
 	size_t stats_size = sizeof(struct __qlcnic_esw_statistics);
+	struct __qlcnic_esw_statistics *stats;
 	dma_addr_t stats_dma_t;
 	void *stats_addr;
 	u32 arg1;
@@ -980,8 +981,21 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 			LSD(stats_dma_t),
 			QLCNIC_CDRP_CMD_GET_ESWITCH_STATS);
 
-	if (!err)
-		memcpy(esw_stats, stats_addr, stats_size);
+	if (!err) {
+		stats = (struct __qlcnic_esw_statistics *)stats_addr;
+		esw_stats->context_id = le16_to_cpu(stats->context_id);
+		esw_stats->version = le16_to_cpu(stats->version);
+		esw_stats->size = le16_to_cpu(stats->size);
+		esw_stats->multicast_frames =
+				le64_to_cpu(stats->multicast_frames);
+		esw_stats->broadcast_frames =
+				le64_to_cpu(stats->broadcast_frames);
+		esw_stats->unicast_frames = le64_to_cpu(stats->unicast_frames);
+		esw_stats->dropped_frames = le64_to_cpu(stats->dropped_frames);
+		esw_stats->local_frames = le64_to_cpu(stats->local_frames);
+		esw_stats->errors = le64_to_cpu(stats->errors);
+		esw_stats->numbytes = le64_to_cpu(stats->numbytes);
+	}
 
 	pci_free_consistent(adapter->pdev, stats_size, stats_addr,
 		stats_dma_t);
-- 
1.6.0.2

