From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH 4/7] bnx2x: simplify TPA sanity check
Date: Tue, 30 Aug 2011 16:30:43 +0200
Message-ID: <1314714646-3642-5-git-send-email-mschmidt@redhat.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
Cc: vladz@broadcom.com, dmitry@broadcom.com, eilong@broadcom.com,
	Michal Schmidt <mschmidt@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50827 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754535Ab1H3ObP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 10:31:15 -0400
In-Reply-To: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the TPA branch we already know the CQE type is either START or STOP.
No need to test for that. Even if the type were to differ, we wouldn't
want to suppress the error message.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index f1fea58..fe5be0c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -634,9 +634,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 		if (!CQE_TYPE_FAST(cqe_fp_type)) {
 #ifdef BNX2X_STOP_ON_ERROR
 			/* sanity check */
-			if (fp->disable_tpa &&
-			    (CQE_TYPE_START(cqe_fp_type) ||
-			     CQE_TYPE_STOP(cqe_fp_type)))
+			if (fp->disable_tpa)
 				BNX2X_ERR("START/STOP packet while "
 					  "disable_tpa type %x\n",
 					  CQE_TYPE(cqe_fp_type));
-- 
1.7.6
