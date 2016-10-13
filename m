From: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
Subject: [PATCH net 1/3] qed: Fix static checker warning.
Date: Thu, 13 Oct 2016 22:57:01 +0300
Message-ID: <1476388623-31032-2-git-send-email-Yuval.Mintz@caviumnetworks.com>
References: <1476388623-31032-1-git-send-email-Yuval.Mintz@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <arnd@arndb.de>, <dan.carpenter@oracle.com>,
        Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49757 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756822AbcJMT5z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 15:57:55 -0400
In-Reply-To: <1476388623-31032-1-git-send-email-Yuval.Mintz@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch compains about qed_roce_ll2_tx() dereference
of the 'cdev' variable while testing its validity later.
As the validation checking is an over-kill [variable would always
be set], simply remove it.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Fixes: abd49676c707 ("qed: Add RoCE ll2 & GSI support")
Signed-off-by: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
---
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index 76831a3..c73638c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -2809,11 +2809,6 @@ static int qed_roce_ll2_stop(struct qed_dev *cdev)
 	struct qed_roce_ll2_info *roce_ll2 = hwfn->ll2;
 	int rc;
 
-	if (!cdev) {
-		DP_ERR(cdev, "qed roce ll2 stop: invalid cdev\n");
-		return -EINVAL;
-	}
-
 	if (roce_ll2->handle == QED_LL2_UNUSED_HANDLE) {
 		DP_ERR(cdev, "qed roce ll2 stop: cannot stop an unused LL2\n");
 		return -EINVAL;
@@ -2850,7 +2845,7 @@ static int qed_roce_ll2_tx(struct qed_dev *cdev,
 	int rc;
 	int i;
 
-	if (!cdev || !pkt || !params) {
+	if (!pkt || !params) {
 		DP_ERR(cdev,
 		       "roce ll2 tx: failed tx because one of the following is NULL - drv=%p, pkt=%p, params=%p\n",
 		       cdev, pkt, params);
-- 
1.9.3
