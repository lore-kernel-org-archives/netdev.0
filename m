From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net 1/2] qlcnic: Fix panic while dumping TX queues on TX timeout
Date: Tue, 6 May 2014 03:46:48 -0400
Message-ID: <1399362409-17039-2-git-send-email-rajesh.borundia@qlogic.com>
References: <1399362409-17039-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:42227 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934240AbaEFIPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 04:15:34 -0400
In-Reply-To: <1399362409-17039-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o In case of non-multi TX queue mode driver does not initialize "crb_intr_mask" pointer
  and driver was accessing that un-initialized pointer while dumping TX queue.
  So dump "crb_intr_mask" only when it is initilaized.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 0bc9148..be78951 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2943,9 +2943,13 @@ static void qlcnic_dump_tx_rings(struct qlcnic_adapter *adapter)
 			    tx_ring->tx_stats.xmit_called,
 			    tx_ring->tx_stats.xmit_on,
 			    tx_ring->tx_stats.xmit_off);
+
+		if (tx_ring->crb_intr_mask)
+			netdev_info(netdev, "crb_intr_mask=%d\n",
+				    readl(tx_ring->crb_intr_mask));
+
 		netdev_info(netdev,
-			    "crb_intr_mask=%d, hw_producer=%d, sw_producer=%d sw_consumer=%d, hw_consumer=%d\n",
-			    readl(tx_ring->crb_intr_mask),
+			    "hw_producer=%d, sw_producer=%d sw_consumer=%d, hw_consumer=%d\n",
 			    readl(tx_ring->crb_cmd_producer),
 			    tx_ring->producer, tx_ring->sw_consumer,
 			    le32_to_cpu(*(tx_ring->hw_consumer)));
-- 
1.6.3.3
