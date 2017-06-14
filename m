From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net-next] qed: Fix an off by one bug
Date: Wed, 14 Jun 2017 12:10:10 +0300
Message-ID: <20170614091009.GA29394@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ariel Elior <Ariel.Elior@cavium.com>, everest-linux-l2@cavium.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@cavium.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The p_l2_info->pp_qid_usage[] array has "p_l2_info->queues" elements so
the > here should be a >= or we write beyond the end of the array.

Fixes: bbe3f233ec5e ("qed: Assign a unique per-queue index to queue-cid")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index cb8b05dbfc6e..e57699bfbdfa 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -161,7 +161,7 @@ static bool qed_eth_queue_qid_usage_add(struct qed_hwfn *p_hwfn,
 
 	mutex_lock(&p_l2_info->lock);
 
-	if (queue_id > p_l2_info->queues) {
+	if (queue_id >= p_l2_info->queues) {
 		DP_NOTICE(p_hwfn,
 			  "Requested to increase usage for qzone %04x out of %08x\n",
 			  queue_id, p_l2_info->queues);
