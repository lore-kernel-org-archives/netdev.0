From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 08/10] qede: Prevent index problems in loopback test
Date: Sun, 19 Feb 2017 15:26:21 +0200
Message-ID: <1487510783-19919-9-git-send-email-Yuval.Mintz@cavium.com>
References: <1487510783-19919-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:54366 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752065AbdBSN1H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 08:27:07 -0500
In-Reply-To: <1487510783-19919-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>

Driver currently utilizes the same loop variable in two
nested loops.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 1c48f44..6860f02 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -1296,7 +1296,7 @@ static int qede_selftest_receive_traffic(struct qede_dev *edev)
 	struct qede_rx_queue *rxq = NULL;
 	struct sw_rx_data *sw_rx_data;
 	union eth_rx_cqe *cqe;
-	int i, rc = 0;
+	int i, iter, rc = 0;
 	u8 *data_ptr;
 
 	for_each_queue(i) {
@@ -1315,7 +1315,7 @@ static int qede_selftest_receive_traffic(struct qede_dev *edev)
 	 * enabled. This is because the queue 0 is configured as the default
 	 * queue and that the loopback traffic is not IP.
 	 */
-	for (i = 0; i < QEDE_SELFTEST_POLL_COUNT; i++) {
+	for (iter = 0; iter < QEDE_SELFTEST_POLL_COUNT; iter++) {
 		if (!qede_has_rx_work(rxq)) {
 			usleep_range(100, 200);
 			continue;
@@ -1362,7 +1362,7 @@ static int qede_selftest_receive_traffic(struct qede_dev *edev)
 		qed_chain_recycle_consumed(&rxq->rx_comp_ring);
 	}
 
-	if (i == QEDE_SELFTEST_POLL_COUNT) {
+	if (iter == QEDE_SELFTEST_POLL_COUNT) {
 		DP_NOTICE(edev, "Failed to receive the traffic\n");
 		return -1;
 	}
-- 
1.9.3
