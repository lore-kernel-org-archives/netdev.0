From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/4] cnic: Handle RAMROD_CMD_ID_CLOSE error.
Date: Wed, 27 Jun 2012 18:08:22 -0700
Message-ID: <1340845704-12580-4-git-send-email-mchan@broadcom.com>
References: <1340845704-12580-1-git-send-email-mchan@broadcom.com>
 <1340845704-12580-2-git-send-email-mchan@broadcom.com>
 <1340845704-12580-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4746 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754030Ab2F1A5Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 20:57:25 -0400
In-Reply-To: <1340845704-12580-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eddie Wai <eddie.wai@broadcom.com>

If firmware returns error status, proceed to close the iSCSI connection.
Update version to 2.5.11.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c    |    9 +++++++++
 drivers/net/ethernet/broadcom/cnic_if.h |    4 ++--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index ec43df1..f897306 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -3953,6 +3953,15 @@ static void cnic_cm_process_kcqe(struct cnic_dev *dev, struct kcqe *kcqe)
 		cnic_cm_upcall(cp, csk, opcode);
 		break;
 
+	case L5CM_RAMROD_CMD_ID_CLOSE:
+		if (l4kcqe->status != 0) {
+			netdev_warn(dev->netdev, "RAMROD CLOSE compl with "
+				    "status 0x%x\n", l4kcqe->status);
+			opcode = L4_KCQE_OPCODE_VALUE_CLOSE_COMP;
+			/* Fall through */
+		} else {
+			break;
+		}
 	case L4_KCQE_OPCODE_VALUE_RESET_RECEIVED:
 	case L4_KCQE_OPCODE_VALUE_CLOSE_COMP:
 	case L4_KCQE_OPCODE_VALUE_RESET_COMP:
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index d63d455..54f68f0 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -14,8 +14,8 @@
 
 #include "bnx2x/bnx2x_mfw_req.h"
 
-#define CNIC_MODULE_VERSION	"2.5.10"
-#define CNIC_MODULE_RELDATE	"March 21, 2012"
+#define CNIC_MODULE_VERSION	"2.5.11"
+#define CNIC_MODULE_RELDATE	"June 27, 2012"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.7.1
