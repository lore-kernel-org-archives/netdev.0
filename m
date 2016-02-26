From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] bna: fix list corruption
Date: Fri, 26 Feb 2016 09:15:50 +0100
Message-ID: <1456474550-16747-1-git-send-email-ivecera@redhat.com>
Cc: Rasesh Mody <rasesh.mody@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35556 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753799AbcBZIQG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 03:16:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use list_move_tail() to move MAC address entry from list of pending
to list of active entries. Simple list_add_tail() leaves the entry
also in the first list, this leads to list corruption.

Cc: Rasesh Mody <rasesh.mody@qlogic.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 04b0d16..95bc470 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -987,7 +987,7 @@ bna_rxf_ucast_cfg_apply(struct bna_rxf *rxf)
 	if (!list_empty(&rxf->ucast_pending_add_q)) {
 		mac = list_first_entry(&rxf->ucast_pending_add_q,
 				       struct bna_mac, qe);
-		list_add_tail(&mac->qe, &rxf->ucast_active_q);
+		list_move_tail(&mac->qe, &rxf->ucast_active_q);
 		bna_bfi_ucast_req(rxf, mac, BFI_ENET_H2I_MAC_UCAST_ADD_REQ);
 		return 1;
 	}
-- 
2.4.10
