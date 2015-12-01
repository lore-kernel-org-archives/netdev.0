From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH 4/6] net: thunderx: Set CQ timer threshold properly
Date: Tue,  1 Dec 2015 14:43:41 +0530
Message-ID: <1448961223-41888-5-git-send-email-sunil.kovvuri@gmail.com>
References: <y>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <y>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Properly set CQ timer threshold and also set it to 2us.
With previous incorrect settings it was set to 0.5us which is too less.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h          |    5 ++---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |    2 +-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |    2 +-
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index d3950b2..39ca674 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -120,10 +120,9 @@
  * Calculated for SCLK of 700Mhz
  * value written should be a 1/16th of what is expected
  *
- * 1 tick per 0.05usec = value of 2.2
- * This 10% would be covered in CQ timer thresh value
+ * 1 tick per 0.025usec
  */
-#define NICPF_CLK_PER_INT_TICK		2
+#define NICPF_CLK_PER_INT_TICK		1
 
 /* Time to wait before we decide that a SQ is stuck.
  *
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index e404ea8..206b6a7 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -592,7 +592,7 @@ void nicvf_cmp_queue_config(struct nicvf *nic, struct queue_set *qs,
 	/* Set threshold value for interrupt generation */
 	nicvf_queue_reg_write(nic, NIC_QSET_CQ_0_7_THRESH, qidx, cq->thresh);
 	nicvf_queue_reg_write(nic, NIC_QSET_CQ_0_7_CFG2,
-			      qidx, nic->cq_coalesce_usecs);
+			      qidx, CMP_QUEUE_TIMER_THRESH);
 }
 
 /* Configures transmit queue */
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
index b1e93a9..457eaee 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
@@ -76,7 +76,7 @@
 #define CMP_QSIZE		CMP_QUEUE_SIZE3
 #define CMP_QUEUE_LEN		(1ULL << (CMP_QSIZE + 10))
 #define CMP_QUEUE_CQE_THRESH	0
-#define CMP_QUEUE_TIMER_THRESH	220 /* 10usec */
+#define CMP_QUEUE_TIMER_THRESH	80 /* ~2usec */
 
 #define RBDR_SIZE		RBDR_SIZE0
 #define RCV_BUF_COUNT		(1ULL << (RBDR_SIZE + 13))
-- 
1.7.1
