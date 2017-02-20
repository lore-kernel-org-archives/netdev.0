From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 08/10] qede: Prevent index problems in loopback test
Date: Mon, 20 Feb 2017 22:43:37 +0200
Message-ID: <1487623419-6442-9-git-send-email-Yuval.Mintz@cavium.com>
References: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46568 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750827AbdBTVCJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 16:02:09 -0500
In-Reply-To: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
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
index c02754d..8979531 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -1333,7 +1333,7 @@ static int qede_selftest_receive_traffic(struct qede_dev *edev)
 	struct qede_rx_queue *rxq = NULL;
 	struct sw_rx_data *sw_rx_data;
 	union eth_rx_cqe *cqe;
-	int i, rc = 0;
+	int i, iter, rc = 0;
 	u8 *data_ptr;
 
 	for_each_queue(i) {
@@ -1352,7 +1352,7 @@ static int qede_selftest_receive_traffic(struct qede_dev *edev)
 	 * enabled. This is because the queue 0 is configured as the default
 	 * queue and that the loopback traffic is not IP.
 	 */
-	for (i = 0; i < QEDE_SELFTEST_POLL_COUNT; i++) {
+	for (iter = 0; iter < QEDE_SELFTEST_POLL_COUNT; iter++) {
 		if (!qede_has_rx_work(rxq)) {
 			usleep_range(100, 200);
 			continue;
@@ -1399,7 +1399,7 @@ static int qede_selftest_receive_traffic(struct qede_dev *edev)
 		qed_chain_recycle_consumed(&rxq->rx_comp_ring);
 	}
 
-	if (i == QEDE_SELFTEST_POLL_COUNT) {
+	if (iter == QEDE_SELFTEST_POLL_COUNT) {
 		DP_NOTICE(edev, "Failed to receive the traffic\n");
 		return -1;
 	}
-- 
1.9.3
