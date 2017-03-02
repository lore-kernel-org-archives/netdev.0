From: Robert Foss <robert.foss@collabora.com>
Subject: [PATCH v1] qed: Fix copy of uninitialized memory
Date: Wed,  1 Mar 2017 22:55:08 -0500
Message-ID: <20170302035508.5731-1-robert.foss@collabora.com>
Cc: Robert Foss <robert.foss@collabora.com>
To: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:46094 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753378AbdCBED0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 23:03:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In qed_ll2_start_ooo() the ll2_info variable is uninitialized and then
passed to qed_ll2_acquire_connection() where it is copied into a new
memory space.

This shouldn't cause any issue as long as non of the copied memory is
every read.
But the potential for a bug being introduced by reading this memory
is real.

Detected by CoverityScan, CID#1399632 ("Uninitialized scalar variable")

Signed-off-by: Robert Foss <robert.foss@collabora.com>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index 9a0b9af10a57..5fb34db377c8 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -968,7 +968,7 @@ static int qed_ll2_start_ooo(struct qed_dev *cdev,
 {
 	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
 	u8 *handle = &hwfn->pf_params.iscsi_pf_params.ll2_ooo_queue_id;
-	struct qed_ll2_conn ll2_info;
+	struct qed_ll2_conn ll2_info = { 0 };
 	int rc;
 
 	ll2_info.conn_type = QED_LL2_TYPE_ISCSI_OOO;
-- 
2.11.0.453.g787f75f05
