From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next 14/14] Fix broadcom/bnx2x
Date: Tue, 19 Jun 2012 18:14:08 +0300
Message-ID: <1340118848-30978-15-git-send-email-yuvalmin@broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4204 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754415Ab2FSPQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:16:52 -0400
In-Reply-To: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 7cd99b7..99daadb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -807,9 +807,10 @@ static inline void bnx2x_disable_msi(struct bnx2x *bp)
 
 static inline int bnx2x_calc_num_queues(struct bnx2x *bp)
 {
-	return  num_queues ?
-		 min_t(int, num_queues, BNX2X_MAX_QUEUES(bp)) :
-		 min_t(int, num_online_cpus(), BNX2X_MAX_QUEUES(bp));
+	int nqs = num_queues ? (int) num_queues :
+		  min_t(int, num_online_cpus(), DEFAULT_MAX_NUM_RSS_QUEUES);
+
+	return min_t(int, nqs, BNX2X_MAX_QUEUES(bp));
 }
 
 static inline void bnx2x_clear_sge_mask_next_elems(struct bnx2x_fastpath *fp)
-- 
1.7.9.rc2
