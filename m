From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 5/7] bnx2x: define fields of struct cfc_del_event_data as little-endian
Date: Wed,  2 Mar 2016 13:47:09 +0100
Message-ID: <1456922831-15071-6-git-send-email-mschmidt@redhat.com>
References: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40145 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755495AbcCBMo0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 07:44:26 -0500
In-Reply-To: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There were no missing endianness conversions in this case, but the
fields of struct cfc_del_event_data should be defined as little-endian
to get rid of the ugly (__force __le32) casts.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h   | 6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  | 3 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 3 +--
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 1058591..a24909a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -4896,9 +4896,9 @@ struct c2s_pri_trans_table_entry {
  * cfc delete event data
  */
 struct cfc_del_event_data {
-	u32 cid;
-	u32 reserved0;
-	u32 reserved1;
+	__le32 cid;
+	__le32 reserved0;
+	__le32 reserved1;
 };
 
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 0e0bcbd..9f5716a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -5501,8 +5501,7 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 			 */
 
 			/* elem CID originates from FW; actually LE */
-			cid = SW_CID((__force __le32)
-				     elem->message.data.cfc_del_event.cid);
+			cid = SW_CID(elem->message.data.cfc_del_event.cid);
 
 			DP(BNX2X_MSG_SP,
 			   "got delete ramrod for MULTI[%d]\n", cid);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 55fcc21..632daff 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1747,8 +1747,7 @@ int bnx2x_iov_eq_sp_event(struct bnx2x *bp, union event_ring_elem *elem)
 
 	switch (opcode) {
 	case EVENT_RING_OPCODE_CFC_DEL:
-		cid = SW_CID((__force __le32)
-			     elem->message.data.cfc_del_event.cid);
+		cid = SW_CID(elem->message.data.cfc_del_event.cid);
 		DP(BNX2X_MSG_IOV, "checking cfc-del comp cid=%d\n", cid);
 		break;
 	case EVENT_RING_OPCODE_CLASSIFICATION_RULES:
-- 
2.5.0
