From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH for-next 07/11] IB/hns: Modify the macro for the timeout when cmd process
Date: Fri, 4 Nov 2016 16:36:29 +0000
Message-ID: <20161104163633.141880-8-salil.mehta@huawei.com>
References: <20161104163633.141880-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161104163633.141880-1-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Wei Hu (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

This patch modified the macro for the timeout when cmd is
processing as follows:
Before modification:
 enum {
	HNS_ROCE_CMD_TIME_CLASS_A       = 10000,
	HNS_ROCE_CMD_TIME_CLASS_B       = 10000,
	HNS_ROCE_CMD_TIME_CLASS_C       = 10000,
 };
After modification:
 #define HNS_ROCE_CMD_TIMEOUT_MSECS	10000

Signed-off-by: Wei Hu (Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Salil Mehta  <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/hw/hns/hns_roce_cmd.h   |    7 +------
 drivers/infiniband/hw/hns/hns_roce_cq.c    |    4 ++--
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c |    8 ++++----
 drivers/infiniband/hw/hns/hns_roce_mr.c    |    4 ++--
 4 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_cmd.h b/drivers/infiniband/hw/hns/hns_roce_cmd.h
index e3997d3..ed14ad3 100644
--- a/drivers/infiniband/hw/hns/hns_roce_cmd.h
+++ b/drivers/infiniband/hw/hns/hns_roce_cmd.h
@@ -34,6 +34,7 @@
 #define _HNS_ROCE_CMD_H
 
 #define HNS_ROCE_MAILBOX_SIZE		4096
+#define HNS_ROCE_CMD_TIMEOUT_MSECS	10000
 
 enum {
 	/* TPT commands */
@@ -57,12 +58,6 @@ enum {
 	HNS_ROCE_CMD_QUERY_QP		= 0x22,
 };
 
-enum {
-	HNS_ROCE_CMD_TIME_CLASS_A	= 10000,
-	HNS_ROCE_CMD_TIME_CLASS_B	= 10000,
-	HNS_ROCE_CMD_TIME_CLASS_C	= 10000,
-};
-
 struct hns_roce_cmd_mailbox {
 	void		       *buf;
 	dma_addr_t		dma;
diff --git a/drivers/infiniband/hw/hns/hns_roce_cq.c b/drivers/infiniband/hw/hns/hns_roce_cq.c
index 5dc8d92..461a273 100644
--- a/drivers/infiniband/hw/hns/hns_roce_cq.c
+++ b/drivers/infiniband/hw/hns/hns_roce_cq.c
@@ -77,7 +77,7 @@ static int hns_roce_sw2hw_cq(struct hns_roce_dev *dev,
 			     unsigned long cq_num)
 {
 	return hns_roce_cmd_mbox(dev, mailbox->dma, 0, cq_num, 0,
-			    HNS_ROCE_CMD_SW2HW_CQ, HNS_ROCE_CMD_TIME_CLASS_A);
+			    HNS_ROCE_CMD_SW2HW_CQ, HNS_ROCE_CMD_TIMEOUT_MSECS);
 }
 
 static int hns_roce_cq_alloc(struct hns_roce_dev *hr_dev, int nent,
@@ -176,7 +176,7 @@ static int hns_roce_hw2sw_cq(struct hns_roce_dev *dev,
 {
 	return hns_roce_cmd_mbox(dev, 0, mailbox ? mailbox->dma : 0, cq_num,
 				 mailbox ? 0 : 1, HNS_ROCE_CMD_HW2SW_CQ,
-				 HNS_ROCE_CMD_TIME_CLASS_A);
+				 HNS_ROCE_CMD_TIMEOUT_MSECS);
 }
 
 static void hns_roce_free_cq(struct hns_roce_dev *hr_dev,
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index 2d48406..c39a9b2 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -1871,12 +1871,12 @@ static int hns_roce_v1_qp_modify(struct hns_roce_dev *hr_dev,
 	if (op[cur_state][new_state] == HNS_ROCE_CMD_2RST_QP)
 		return hns_roce_cmd_mbox(hr_dev, 0, 0, hr_qp->qpn, 2,
 					 HNS_ROCE_CMD_2RST_QP,
-					 HNS_ROCE_CMD_TIME_CLASS_A);
+					 HNS_ROCE_CMD_TIMEOUT_MSECS);
 
 	if (op[cur_state][new_state] == HNS_ROCE_CMD_2ERR_QP)
 		return hns_roce_cmd_mbox(hr_dev, 0, 0, hr_qp->qpn, 2,
 					 HNS_ROCE_CMD_2ERR_QP,
-					 HNS_ROCE_CMD_TIME_CLASS_A);
+					 HNS_ROCE_CMD_TIMEOUT_MSECS);
 
 	mailbox = hns_roce_alloc_cmd_mailbox(hr_dev);
 	if (IS_ERR(mailbox))
@@ -1886,7 +1886,7 @@ static int hns_roce_v1_qp_modify(struct hns_roce_dev *hr_dev,
 
 	ret = hns_roce_cmd_mbox(hr_dev, mailbox->dma, 0, hr_qp->qpn, 0,
 				op[cur_state][new_state],
-				HNS_ROCE_CMD_TIME_CLASS_C);
+				HNS_ROCE_CMD_TIMEOUT_MSECS);
 
 	hns_roce_free_cmd_mailbox(hr_dev, mailbox);
 	return ret;
@@ -2681,7 +2681,7 @@ static int hns_roce_v1_query_qpc(struct hns_roce_dev *hr_dev,
 
 	ret = hns_roce_cmd_mbox(hr_dev, 0, mailbox->dma, hr_qp->qpn, 0,
 				HNS_ROCE_CMD_QUERY_QP,
-				HNS_ROCE_CMD_TIME_CLASS_A);
+				HNS_ROCE_CMD_TIMEOUT_MSECS);
 	if (!ret)
 		memcpy(hr_context, mailbox->buf, sizeof(*hr_context));
 	else
diff --git a/drivers/infiniband/hw/hns/hns_roce_mr.c b/drivers/infiniband/hw/hns/hns_roce_mr.c
index d3dfb5f..2227962 100644
--- a/drivers/infiniband/hw/hns/hns_roce_mr.c
+++ b/drivers/infiniband/hw/hns/hns_roce_mr.c
@@ -53,7 +53,7 @@ static int hns_roce_sw2hw_mpt(struct hns_roce_dev *hr_dev,
 {
 	return hns_roce_cmd_mbox(hr_dev, mailbox->dma, 0, mpt_index, 0,
 				 HNS_ROCE_CMD_SW2HW_MPT,
-				 HNS_ROCE_CMD_TIME_CLASS_B);
+				 HNS_ROCE_CMD_TIMEOUT_MSECS);
 }
 
 static int hns_roce_hw2sw_mpt(struct hns_roce_dev *hr_dev,
@@ -62,7 +62,7 @@ static int hns_roce_hw2sw_mpt(struct hns_roce_dev *hr_dev,
 {
 	return hns_roce_cmd_mbox(hr_dev, 0, mailbox ? mailbox->dma : 0,
 				 mpt_index, !mailbox, HNS_ROCE_CMD_HW2SW_MPT,
-				 HNS_ROCE_CMD_TIME_CLASS_B);
+				 HNS_ROCE_CMD_TIMEOUT_MSECS);
 }
 
 static int hns_roce_buddy_alloc(struct hns_roce_buddy *buddy, int order,
-- 
1.7.9.5


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
