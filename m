From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH v2] qed: Fix to use list_for_each_entry_safe() when delete items
Date: Mon, 10 Oct 2016 14:08:28 +0000
Message-ID: <1476108508-14376-1-git-send-email-weiyj.lk@gmail.com>
References: <1476019942-6837-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, everest-linux-l2@qlogic.com,
        netdev@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35298 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752653AbcJJOIi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 10:08:38 -0400
Received: by mail-pa0-f68.google.com with SMTP id qn10so7280746pac.2
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 07:08:38 -0700 (PDT)
In-Reply-To: <1476019942-6837-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Since we will remove items off the list using list_del() we need
to use a safe version of the list_for_each_entry() macro aptly named
list_for_each_entry_safe().

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
Acked-by: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
---
v1 -> v2: use tmp_buffer instead of tmp
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index a6db107..02a8be2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -1517,7 +1517,7 @@ static void qed_ll2_register_cb_ops(struct qed_dev *cdev,
 static int qed_ll2_start(struct qed_dev *cdev, struct qed_ll2_params *params)
 {
 	struct qed_ll2_info ll2_info;
-	struct qed_ll2_buffer *buffer;
+	struct qed_ll2_buffer *buffer, *tmp_buffer;
 	enum qed_ll2_conn_type conn_type;
 	struct qed_ptt *p_ptt;
 	int rc, i;
@@ -1587,7 +1587,7 @@ static int qed_ll2_start(struct qed_dev *cdev, struct qed_ll2_params *params)
 
 	/* Post all Rx buffers to FW */
 	spin_lock_bh(&cdev->ll2->lock);
-	list_for_each_entry(buffer, &cdev->ll2->list, list) {
+	list_for_each_entry_safe(buffer, tmp_buffer, &cdev->ll2->list, list) {
 		rc = qed_ll2_post_rx_buffer(QED_LEADING_HWFN(cdev),
 					    cdev->ll2->handle,
 					    buffer->phys_addr, 0, buffer, 1);
