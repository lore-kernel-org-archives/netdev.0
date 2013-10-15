From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 1/2] be2net: pass if_id for v1 and V2 versions of TX_CREATE cmd
Date: Tue, 15 Oct 2013 17:26:27 +0530
Message-ID: <1381838188-9625-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:26238 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758116Ab3JOLwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 07:52:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

It is a required field for all TX_CREATE cmd versions > 0.
This fixes a driver initialization failure, caused by recent SH-R Firmwares
(versions > 10.0.639.0) failing the TX_CREATE cmd when if_id field is
not passed.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index bd0e0c0..c08fd32 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1198,7 +1198,6 @@ int be_cmd_txq_create(struct be_adapter *adapter, struct be_tx_obj *txo)
 
 	if (lancer_chip(adapter)) {
 		req->hdr.version = 1;
-		req->if_id = cpu_to_le16(adapter->if_handle);
 	} else if (BEx_chip(adapter)) {
 		if (adapter->function_caps & BE_FUNCTION_CAPS_SUPER_NIC)
 			req->hdr.version = 2;
@@ -1206,6 +1205,8 @@ int be_cmd_txq_create(struct be_adapter *adapter, struct be_tx_obj *txo)
 		req->hdr.version = 2;
 	}
 
+	if (req->hdr.version > 0)
+		req->if_id = cpu_to_le16(adapter->if_handle);
 	req->num_pages = PAGES_4K_SPANNED(q_mem->va, q_mem->size);
 	req->ulp_num = BE_ULP1_NUM;
 	req->type = BE_ETH_TX_RING_TYPE_STANDARD;
-- 
1.7.1
