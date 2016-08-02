From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] qed: Use DEFINE_SPINLOCK() for spinlock
Date: Tue,  2 Aug 2016 13:49:00 +0000
Message-ID: <1470145740-17392-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, everest-linux-l2@qlogic.com,
	netdev@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36188 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965965AbcHBNt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 09:49:57 -0400
Received: by mail-pa0-f66.google.com with SMTP id ez1so12008463pab.3
        for <netdev@vger.kernel.org>; Tue, 02 Aug 2016 06:49:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

spinlock can be initialized automatically with DEFINE_SPINLOCK()
rather than explicitly calling spin_lock_init().

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 0b47ab5..cc623d2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -35,8 +35,7 @@
 #include "qed_sriov.h"
 #include "qed_vf.h"
 
-static spinlock_t qm_lock;
-static bool qm_lock_init = false;
+static DEFINE_SPINLOCK(qm_lock);
 
 /* API common to all protocols */
 enum BAR_ID {
@@ -1003,11 +1002,6 @@ int qed_hw_init(struct qed_dev *cdev,
 		p_hwfn->first_on_engine = (load_code ==
 					   FW_MSG_CODE_DRV_LOAD_ENGINE);
 
-		if (!qm_lock_init) {
-			spin_lock_init(&qm_lock);
-			qm_lock_init = true;
-		}
-
 		switch (load_code) {
 		case FW_MSG_CODE_DRV_LOAD_ENGINE:
 			rc = qed_hw_init_common(p_hwfn, p_hwfn->p_main_ptt,
