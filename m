From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 8/9] bnx2x: Make BP_VF more robust
Date: Sun, 17 Aug 2014 16:47:50 +0300
Message-ID: <1408283271-16176-9-git-send-email-Yuval.Mintz@qlogic.com>
References: <1408283271-16176-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:8806 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751714AbaHQNsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2014 09:48:23 -0400
In-Reply-To: <1408283271-16176-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prevent dereference of pointer in case it's NULL.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index ca1055f..01bafa4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -299,7 +299,8 @@ struct bnx2x_vfdb {
 #define BP_VFDB(bp)		((bp)->vfdb)
 	/* vf array */
 	struct bnx2x_virtf	*vfs;
-#define BP_VF(bp, idx)		(&((bp)->vfdb->vfs[idx]))
+#define BP_VF(bp, idx)		((BP_VFDB(bp) && (bp)->vfdb->vfs) ? \
+					&((bp)->vfdb->vfs[idx]) : NULL)
 #define bnx2x_vf(bp, idx, var)	((bp)->vfdb->vfs[idx].var)
 
 	/* queue array - for all vfs */
-- 
1.7.1
