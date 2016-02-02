From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 2/8] be2net: check for INSUFFICIENT_PRIVILEGES error
Date: Tue,  2 Feb 2016 15:50:29 +0530
Message-ID: <1454408435-11575-3-git-send-email-sriharsha.basavapatna@broadcom.com>
References: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:63466 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754207AbcBBKj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 05:39:28 -0500
In-Reply-To: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@broadcom.com>

The driver currently logs the message "VF is not privileged to issue
opcode" by checking only the base_status field for UNAUTHORIZED_REQUEST.
Add check to look for INSUFFICIENT_PRIVILEGES in the additional status
field also as not all cmds fail with that base status.

Signed-off-by: Suresh Reddy <suresh.reddy@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 3 ++-
 drivers/net/ethernet/emulex/benet/be_cmds.h | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index b63d8ad..3b665f1 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -236,7 +236,8 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 
 	if (base_status != MCC_STATUS_SUCCESS &&
 	    !be_skip_err_log(opcode, base_status, addl_status)) {
-		if (base_status == MCC_STATUS_UNAUTHORIZED_REQUEST) {
+		if (base_status == MCC_STATUS_UNAUTHORIZED_REQUEST ||
+		    addl_status == MCC_ADDL_STATUS_INSUFFICIENT_PRIVILEGES) {
 			dev_warn(&adapter->pdev->dev,
 				 "VF is not privileged to issue opcode %d-%d\n",
 				 opcode, subsystem);
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 241819b..f260ef3 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -68,7 +68,8 @@ enum mcc_addl_status {
 	MCC_ADDL_STATUS_TOO_MANY_INTERFACES = 0x4a,
 	MCC_ADDL_STATUS_INSUFFICIENT_VLANS = 0xab,
 	MCC_ADDL_STATUS_INVALID_SIGNATURE = 0x56,
-	MCC_ADDL_STATUS_MISSING_SIGNATURE = 0x57
+	MCC_ADDL_STATUS_MISSING_SIGNATURE = 0x57,
+	MCC_ADDL_STATUS_INSUFFICIENT_PRIVILEGES = 0x60
 };
 
 #define CQE_BASE_STATUS_MASK		0xFFFF
-- 
2.3.0.rc2
