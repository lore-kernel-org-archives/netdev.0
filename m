From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] qed: fix invalid use of sizeof in qed_alloc_qm_data()
Date: Tue, 25 Apr 2017 07:07:18 +0000
Message-ID: <20170425070718.14790-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, everest-linux-l2@cavium.com,
        netdev@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35388 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1168040AbdDYHHY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 03:07:24 -0400
Received: by mail-pg0-f66.google.com with SMTP id g2so8962409pge.2
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 00:07:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

sizeof() when applied to a pointer typed expression gives the
size of the pointer, not that of the pointed data.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 2498785..4fa5a1e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -820,7 +820,7 @@ static int qed_alloc_qm_data(struct qed_hwfn *p_hwfn)
 	if (!qm_info->qm_vport_params)
 		goto alloc_err;
 
-	qm_info->qm_port_params = kzalloc(sizeof(qm_info->qm_port_params) *
+	qm_info->qm_port_params = kzalloc(sizeof(*qm_info->qm_port_params) *
 					  p_hwfn->cdev->num_ports_in_engines,
 					  GFP_KERNEL);
 	if (!qm_info->qm_port_params)
