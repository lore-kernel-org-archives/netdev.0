From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net V1 4/6] mlx4_core: removed function index from vf.
Date: Thu, 19 Jan 2012 21:45:19 +0200
Message-ID: <4F1872CF.3090003@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<marcela@dev.mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:54690 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932675Ab2ASTpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 14:45:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Apfelbaum <marcela@dev.mellanox.co.il>

The Virtual Functions should not be aware their function number.

Signed-off-by: Marcel Apfelbaum <marcela@dev.mellanox.co.il>
Reviewed-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/cq.c            |    4 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c            |    4 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |    7 ----
 drivers/net/ethernet/mellanox/mlx4/fw.h            |    1 -
 drivers/net/ethernet/mellanox/mlx4/main.c          |    1 -
 drivers/net/ethernet/mellanox/mlx4/mr.c            |    2 +-
 drivers/net/ethernet/mellanox/mlx4/pd.c            |    3 +-
 drivers/net/ethernet/mellanox/mlx4/qp.c            |    2 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   35 --------------------
 drivers/net/ethernet/mellanox/mlx4/srq.c           |    2 +-
 10 files changed, 8 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index 475f9d6..7e64033 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -96,7 +96,7 @@ void mlx4_cq_event(struct mlx4_dev *dev, u32 cqn, int event_type)
 static int mlx4_SW2HW_CQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			 int cq_num)
 {
-	return mlx4_cmd(dev, mailbox->dma | dev->caps.function, cq_num, 0,
+	return mlx4_cmd(dev, mailbox->dma, cq_num, 0,
 			MLX4_CMD_SW2HW_CQ, MLX4_CMD_TIME_CLASS_A,
 			MLX4_CMD_WRAPPED);
 }
@@ -111,7 +111,7 @@ static int mlx4_MODIFY_CQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox
 static int mlx4_HW2SW_CQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			 int cq_num)
 {
-	return mlx4_cmd_box(dev, dev->caps.function, mailbox ? mailbox->dma : 0,
+	return mlx4_cmd_box(dev, 0, mailbox ? mailbox->dma : 0,
 			    cq_num, mailbox ? 0 : 1, MLX4_CMD_HW2SW_CQ,
 			    MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 1e9b55e..e163de6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -546,7 +546,7 @@ static int mlx4_MAP_EQ(struct mlx4_dev *dev, u64 event_mask, int unmap,
 static int mlx4_SW2HW_EQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			 int eq_num)
 {
-	return mlx4_cmd(dev, mailbox->dma | dev->caps.function, eq_num, 0,
+	return mlx4_cmd(dev, mailbox->dma, eq_num, 0,
 			MLX4_CMD_SW2HW_EQ, MLX4_CMD_TIME_CLASS_A,
 			MLX4_CMD_WRAPPED);
 }
@@ -554,7 +554,7 @@ static int mlx4_SW2HW_EQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 static int mlx4_HW2SW_EQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			 int eq_num)
 {
-	return mlx4_cmd_box(dev, dev->caps.function, mailbox->dma, eq_num,
+	return mlx4_cmd_box(dev, 0, mailbox->dma, eq_num,
 			    0, MLX4_CMD_HW2SW_EQ, MLX4_CMD_TIME_CLASS_A,
 			    MLX4_CMD_WRAPPED);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index a424a19..8a21e10 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -158,7 +158,6 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 
 #define QUERY_FUNC_CAP_FLAGS_OFFSET		0x0
 #define QUERY_FUNC_CAP_NUM_PORTS_OFFSET		0x1
-#define QUERY_FUNC_CAP_FUNCTION_OFFSET		0x3
 #define QUERY_FUNC_CAP_PF_BHVR_OFFSET		0x4
 #define QUERY_FUNC_CAP_QP_QUOTA_OFFSET		0x10
 #define QUERY_FUNC_CAP_CQ_QUOTA_OFFSET		0x14
@@ -182,9 +181,6 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 		field = 1 << 7; /* enable only ethernet interface */
 		MLX4_PUT(outbox->buf, field, QUERY_FUNC_CAP_FLAGS_OFFSET);
 
-		field = slave;
-		MLX4_PUT(outbox->buf, field, QUERY_FUNC_CAP_FUNCTION_OFFSET);
-
 		field = dev->caps.num_ports;
 		MLX4_PUT(outbox->buf, field, QUERY_FUNC_CAP_NUM_PORTS_OFFSET);
 
@@ -249,9 +245,6 @@ int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, struct mlx4_func_cap *func_cap)
 		goto out;
 	}
 
-	MLX4_GET(field, outbox, QUERY_FUNC_CAP_FUNCTION_OFFSET);
-	func_cap->function = field;
-
 	MLX4_GET(field, outbox, QUERY_FUNC_CAP_NUM_PORTS_OFFSET);
 	func_cap->num_ports = field;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 119e0cc..e1a5fa5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -119,7 +119,6 @@ struct mlx4_dev_cap {
 };
 
 struct mlx4_func_cap {
-	u8	function;
 	u8	num_ports;
 	u8	flags;
 	u32	pf_context_behaviour;
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 6bb62c5..91c8bc9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -471,7 +471,6 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 		return -ENOSYS;
 	}
 
-	dev->caps.function		= func_cap.function;
 	dev->caps.num_ports		= func_cap.num_ports;
 	dev->caps.num_qps		= func_cap.qp_quota;
 	dev->caps.num_srqs		= func_cap.srq_quota;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index 01df556..8deeef9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -291,7 +291,7 @@ static u32 key_to_hw_index(u32 key)
 static int mlx4_SW2HW_MPT(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			  int mpt_index)
 {
-	return mlx4_cmd(dev, mailbox->dma | dev->caps.function , mpt_index,
+	return mlx4_cmd(dev, mailbox->dma, mpt_index,
 			0, MLX4_CMD_SW2HW_MPT, MLX4_CMD_TIME_CLASS_B,
 			MLX4_CMD_WRAPPED);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/pd.c b/drivers/net/ethernet/mellanox/mlx4/pd.c
index 5c9a54d..db4746d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/pd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/pd.c
@@ -52,8 +52,7 @@ int mlx4_pd_alloc(struct mlx4_dev *dev, u32 *pdn)
 	*pdn = mlx4_bitmap_alloc(&priv->pd_bitmap);
 	if (*pdn == -1)
 		return -ENOMEM;
-	if (mlx4_is_mfunc(dev))
-		*pdn |= (dev->caps.function + 1) << NOT_MASKED_PD_BITS;
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx4_pd_alloc);
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 6b03ac8..738f950 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -162,7 +162,7 @@ static int __mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 	((struct mlx4_qp_context *) (mailbox->buf + 8))->local_qpn =
 		cpu_to_be32(qp->qpn);
 
-	ret = mlx4_cmd(dev, mailbox->dma | dev->caps.function,
+	ret = mlx4_cmd(dev, mailbox->dma,
 		       qp->qpn | (!!sqd_event << 31),
 		       new_state == MLX4_QP_STATE_RST ? 2 : 0,
 		       op[cur_state][new_state], MLX4_CMD_TIME_CLASS_C, native);
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index ed20751..a30cf19 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -1561,11 +1561,6 @@ static int mr_get_mtt_size(struct mlx4_mpt_entry *mpt)
 	return be32_to_cpu(mpt->mtt_sz);
 }
 
-static int mr_get_pdn(struct mlx4_mpt_entry *mpt)
-{
-	return be32_to_cpu(mpt->pd_flags) & 0xffffff;
-}
-
 static int qp_get_mtt_addr(struct mlx4_qp_context *qpc)
 {
 	return be32_to_cpu(qpc->mtt_base_addr_l) & 0xfffffff8;
@@ -1602,16 +1597,6 @@ static int qp_get_mtt_size(struct mlx4_qp_context *qpc)
 	return total_pages;
 }
 
-static int qp_get_pdn(struct mlx4_qp_context *qpc)
-{
-	return be32_to_cpu(qpc->pd) & 0xffffff;
-}
-
-static int pdn2slave(int pdn)
-{
-	return (pdn >> NOT_MASKED_PD_BITS) - 1;
-}
-
 static int check_mtt_range(struct mlx4_dev *dev, int slave, int start,
 			   int size, struct res_mtt *mtt)
 {
@@ -1656,11 +1641,6 @@ int mlx4_SW2HW_MPT_wrapper(struct mlx4_dev *dev, int slave,
 		mpt->mtt = mtt;
 	}
 
-	if (pdn2slave(mr_get_pdn(inbox->buf)) != slave) {
-		err = -EPERM;
-		goto ex_put;
-	}
-
 	err = mlx4_DMA_wrapper(dev, slave, vhcr, inbox, outbox, cmd);
 	if (err)
 		goto ex_put;
@@ -1792,11 +1772,6 @@ int mlx4_RST2INIT_QP_wrapper(struct mlx4_dev *dev, int slave,
 	if (err)
 		goto ex_put_mtt;
 
-	if (pdn2slave(qp_get_pdn(qpc)) != slave) {
-		err = -EPERM;
-		goto ex_put_mtt;
-	}
-
 	err = get_res(dev, slave, rcqn, RES_CQ, &rcq);
 	if (err)
 		goto ex_put_mtt;
@@ -2289,11 +2264,6 @@ ex_put:
 	return err;
 }
 
-static int srq_get_pdn(struct mlx4_srq_context *srqc)
-{
-	return be32_to_cpu(srqc->pd) & 0xffffff;
-}
-
 static int srq_get_mtt_size(struct mlx4_srq_context *srqc)
 {
 	int log_srq_size = (be32_to_cpu(srqc->state_logsize_srqn) >> 24) & 0xf;
@@ -2333,11 +2303,6 @@ int mlx4_SW2HW_SRQ_wrapper(struct mlx4_dev *dev, int slave,
 	if (err)
 		goto ex_put_mtt;
 
-	if (pdn2slave(srq_get_pdn(srqc)) != slave) {
-		err = -EPERM;
-		goto ex_put_mtt;
-	}
-
 	err = mlx4_DMA_wrapper(dev, slave, vhcr, inbox, outbox, cmd);
 	if (err)
 		goto ex_put_mtt;
diff --git a/drivers/net/ethernet/mellanox/mlx4/srq.c b/drivers/net/ethernet/mellanox/mlx4/srq.c
index 2823fff..feda6c0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/srq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/srq.c
@@ -67,7 +67,7 @@ void mlx4_srq_event(struct mlx4_dev *dev, u32 srqn, int event_type)
 static int mlx4_SW2HW_SRQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			  int srq_num)
 {
-	return mlx4_cmd(dev, mailbox->dma | dev->caps.function, srq_num, 0,
+	return mlx4_cmd(dev, mailbox->dma, srq_num, 0,
 			MLX4_CMD_SW2HW_SRQ, MLX4_CMD_TIME_CLASS_A,
 			MLX4_CMD_WRAPPED);
 }
-- 
1.5.4.3
