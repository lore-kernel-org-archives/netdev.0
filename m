From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 4/7] be2net: Change f/w command versions for Lancer
Date: Mon, 7 Mar 2011 18:38:52 +0530
Message-ID: <cdc5adde-b38b-453d-a561-3ccef2de1cb9@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:52334 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754083Ab1CGNJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 08:09:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change f/w command versions for Lancer

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Subramanian Seetharaman <subbu.seetharaman@emulex.com>
---
 drivers/net/benet/be_cmds.c |    8 +++++++-
 drivers/net/benet/be_cmds.h |    2 +-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 1822ecd..cc3a235 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -726,7 +726,7 @@ int be_cmd_cq_create(struct be_adapter *adapter,
 
 	req->num_pages =  cpu_to_le16(PAGES_4K_SPANNED(q_mem->va, q_mem->size));
 	if (lancer_chip(adapter)) {
-		req->hdr.version = 1;
+		req->hdr.version = 2;
 		req->page_size = 1; /* 1 for 4K */
 		AMAP_SET_BITS(struct amap_cq_context_lancer, coalescwm, ctxt,
 								coalesce_wm);
@@ -862,6 +862,12 @@ int be_cmd_txq_create(struct be_adapter *adapter,
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH, OPCODE_ETH_TX_CREATE,
 		sizeof(*req));
 
+	if (lancer_chip(adapter)) {
+		req->hdr.version = 1;
+		AMAP_SET_BITS(struct amap_tx_context, if_id, ctxt,
+					adapter->if_handle);
+	}
+
 	req->num_pages = PAGES_4K_SPANNED(q_mem->va, q_mem->size);
 	req->ulp_num = BE_ULP1_NUM;
 	req->type = BE_ETH_TX_RING_TYPE_STANDARD;
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 93e5768..5bdaa22 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -430,7 +430,7 @@ struct be_cmd_resp_mcc_create {
 /* Pseudo amap definition in which each bit of the actual structure is defined
  * as a byte: used to calculate offset/shift/mask of each field */
 struct amap_tx_context {
-	u8 rsvd0[16];		/* dword 0 */
+	u8 if_id[16];		/* dword 0 */
 	u8 tx_ring_size[4];	/* dword 0 */
 	u8 rsvd1[26];		/* dword 0 */
 	u8 pci_func_id[8];	/* dword 1 */
-- 
1.6.0.2

