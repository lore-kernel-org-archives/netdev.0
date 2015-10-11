From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] qlcnic: constify qlcnic_mbx_ops structure
Date: Sun, 11 Oct 2015 13:48:05 +0200
Message-ID: <1444564085-12839-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Dept-GELinuxNICDev@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The only instance of a qlcnic_mbx_ops structure is never modified.  Thus
the declaration of the structure and all references to the structure type
can be made const.

In the definition of the qlcnic_mailbox structure, the ops field is no
longer lined up with the other fields.  This was left as is, to avoid a lot
of trivial changes on the other lines.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h         |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 9f0bdd9..37a731b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -4048,7 +4048,7 @@ static void qlcnic_83xx_mailbox_worker(struct work_struct *work)
 	struct qlcnic_mailbox *mbx = container_of(work, struct qlcnic_mailbox,
 						  work);
 	struct qlcnic_adapter *adapter = mbx->adapter;
-	struct qlcnic_mbx_ops *mbx_ops = mbx->ops;
+	const struct qlcnic_mbx_ops *mbx_ops = mbx->ops;
 	struct device *dev = &adapter->pdev->dev;
 	atomic_t *rsp_status = &mbx->rsp_status;
 	struct list_head *head = &mbx->cmd_q;
@@ -4098,7 +4098,7 @@ static void qlcnic_83xx_mailbox_worker(struct work_struct *work)
 	}
 }
 
-static struct qlcnic_mbx_ops qlcnic_83xx_mbx_ops = {
+static const struct qlcnic_mbx_ops qlcnic_83xx_mbx_ops = {
 	.enqueue_cmd    = qlcnic_83xx_enqueue_mbx_cmd,
 	.dequeue_cmd    = qlcnic_83xx_dequeue_mbx_cmd,
 	.decode_resp    = qlcnic_83xx_decode_mbx_rsp,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index d6696cf..46bbea8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1092,7 +1092,7 @@ struct qlcnic_filter_hash {
 struct qlcnic_mailbox {
 	struct workqueue_struct	*work_q;
 	struct qlcnic_adapter	*adapter;
-	struct qlcnic_mbx_ops	*ops;
+	const struct qlcnic_mbx_ops *ops;
 	struct work_struct	work;
 	struct completion	completion;
 	struct list_head	cmd_q;
