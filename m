From: "Benjamin Li" <benli@broadcom.com>
Subject: [PATCH 3/4] bnx2: Fix Sparse warnings
Date: Fri, 18 Jul 2008 14:20:49 -0700
Message-ID: <1216416050-10572-4-git-send-email-benli@broadcom.com>
References: <1216416050-10572-1-git-send-email-benli@broadcom.com>
 <1216416050-10572-2-git-send-email-benli@broadcom.com>
 <1216416050-10572-3-git-send-email-benli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com, "Michael Chan" <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1955 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752884AbYGRVVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 17:21:00 -0400
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.11.18.52]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id D16462B0 for
 <netdev@vger.kernel.org>; Fri, 18 Jul 2008 14:20:51 -0700 (PDT)
In-Reply-To: <1216416050-10572-3-git-send-email-benli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch will fix the following sparse warnings:

/home/benli/sparse/bnx2.c:297:8: warning: symbol 'val' shadows an earlier one
/home/benli/sparse/bnx2.c:286:60: originally declared here
/home/benli/sparse/bnx2.c:7461:7: warning: symbol 'i' shadows an earlier one
/home/benli/sparse/bnx2.c:7265:10: originally declared here

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index dc6f261..c065499 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -294,7 +294,6 @@ bnx2_ctx_wr(struct bnx2 *bp, u32 cid_addr, u32 offset, u32 val)
 		REG_WR(bp, BNX2_CTX_CTX_CTRL,
 		       offset | BNX2_CTX_CTX_CTRL_WRITE_REQ);
 		for (i = 0; i < 5; i++) {
-			u32 val;
 			val = REG_RD(bp, BNX2_CTX_CTX_CTRL);
 			if ((val & BNX2_CTX_CTX_CTRL_WRITE_REQ) == 0)
 				break;
@@ -7458,7 +7457,6 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	reg &= BNX2_CONDITION_MFW_RUN_MASK;
 	if (reg != BNX2_CONDITION_MFW_RUN_UNKNOWN &&
 	    reg != BNX2_CONDITION_MFW_RUN_NONE) {
-		int i;
 		u32 addr = bnx2_shmem_rd(bp, BNX2_MFW_VER_PTR);
 
 		bp->fw_version[j++] = ' ';
-- 
1.5.6.1


