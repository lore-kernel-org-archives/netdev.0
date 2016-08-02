From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] qed: Fix error return code in qed_resc_alloc()
Date: Tue,  2 Aug 2016 00:55:34 +0000
Message-ID: <1470099334-14490-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, everest-linux-l2@qlogic.com,
	netdev@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36657 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbcHBBOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 21:14:30 -0400
Received: by mail-pa0-f68.google.com with SMTP id ez1so10831713pab.3
        for <netdev@vger.kernel.org>; Mon, 01 Aug 2016 18:13:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix to return error code -EINVAL instead of 0 when EQ elements is
too larger, as done elsewhere in this function.

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 1a53c04..648c814 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -509,6 +509,7 @@ int qed_resc_alloc(struct qed_dev *cdev)
 			DP_ERR(p_hwfn,
 			       "Cannot allocate 0x%x EQ elements. The maximum of a u16 chain is 0x%x\n",
 			       n_eqes, 0xFFFF);
+			rc = -EINVAL;
 			goto alloc_err;
 		}
