From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/4 net-next] cnic: Fix Context ID space calculation
Date: Wed, 20 Jul 2011 17:55:22 -0700
Message-ID: <1311209725-10414-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3032 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751822Ab1GUBre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 21:47:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include FCoE CID space only for E2_PLUS devices.  Remove old CID
offset adjustments that are no longer needed.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
---
 drivers/net/cnic.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index ea75f65..455fd0d 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -1172,7 +1172,7 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 
 	cp->iro_arr = ethdev->iro_arr;
 
-	cp->max_cid_space = MAX_ISCSI_TBL_SZ + BNX2X_FCOE_NUM_CONNECTIONS;
+	cp->max_cid_space = MAX_ISCSI_TBL_SZ;
 	cp->iscsi_start_cid = start_cid;
 	cp->fcoe_start_cid = start_cid + MAX_ISCSI_TBL_SZ;
 
@@ -1183,14 +1183,6 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 			cp->fcoe_init_cid = 0x10;
 	}
 
-	if (start_cid < BNX2X_ISCSI_START_CID) {
-		u32 delta = BNX2X_ISCSI_START_CID - start_cid;
-
-		cp->iscsi_start_cid = BNX2X_ISCSI_START_CID;
-		cp->fcoe_start_cid += delta;
-		cp->max_cid_space += delta;
-	}
-
 	cp->iscsi_tbl = kzalloc(sizeof(struct cnic_iscsi) * MAX_ISCSI_TBL_SZ,
 				GFP_KERNEL);
 	if (!cp->iscsi_tbl)
-- 
1.6.4.GIT


