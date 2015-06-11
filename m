From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next v2 09/19] bna: remove prio_change_cbfn oper_state_cbfn from struct bna_tx
Date: Thu, 11 Jun 2015 15:52:21 +0200
Message-ID: <1434030751-28835-10-git-send-email-ivecera@redhat.com>
References: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58142 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754666AbbFKNwR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 09:52:17 -0400
In-Reply-To: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c | 13 -------------
 drivers/net/ethernet/brocade/bna/bna_types.h |  3 ---
 2 files changed, 16 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 27f75d7..471e74d 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -3000,16 +3000,6 @@ do {									\
 	}								\
 } while (0)
 
-#define call_tx_prio_change_cbfn(tx)					\
-do {									\
-	if ((tx)->prio_change_cbfn) {					\
-		void (*cbfn)(struct bnad *, struct bna_tx *);	\
-		cbfn = (tx)->prio_change_cbfn;				\
-		(tx)->prio_change_cbfn = NULL;				\
-		cbfn((tx)->bna->bnad, (tx));				\
-	}								\
-} while (0)
-
 static void bna_tx_mod_cb_tx_stopped(void *tx_mod, struct bna_tx *tx);
 static void bna_bfi_tx_enet_start(struct bna_tx *tx);
 static void bna_tx_enet_stop(struct bna_tx *tx);
@@ -3062,7 +3052,6 @@ bna_tx_sm_stopped(struct bna_tx *tx, enum bna_tx_event event)
 		break;
 
 	case TX_E_PRIO_CHANGE:
-		call_tx_prio_change_cbfn(tx);
 		break;
 
 	case TX_E_BW_UPDATE:
@@ -3232,7 +3221,6 @@ bna_tx_sm_prio_stop_wait(struct bna_tx *tx, enum bna_tx_event event)
 
 	case TX_E_FAIL:
 		bfa_fsm_set_state(tx, bna_tx_sm_failed);
-		call_tx_prio_change_cbfn(tx);
 		tx->tx_cleanup_cbfn(tx->bna->bnad, tx);
 		break;
 
@@ -3253,7 +3241,6 @@ bna_tx_sm_prio_stop_wait(struct bna_tx *tx, enum bna_tx_event event)
 static void
 bna_tx_sm_prio_cleanup_wait_entry(struct bna_tx *tx)
 {
-	call_tx_prio_change_cbfn(tx);
 	tx->tx_cleanup_cbfn(tx->bna->bnad, tx);
 }
 
diff --git a/drivers/net/ethernet/brocade/bna/bna_types.h b/drivers/net/ethernet/brocade/bna/bna_types.h
index 96a02f2..095bd63 100644
--- a/drivers/net/ethernet/brocade/bna/bna_types.h
+++ b/drivers/net/ethernet/brocade/bna/bna_types.h
@@ -495,9 +495,6 @@ struct bna_tx {
 	void (*stop_cbfn)(void *arg, struct bna_tx *tx);
 	void			*stop_cbarg;
 
-	/* callback for bna_tx_prio_set() */
-	void (*prio_change_cbfn)(struct bnad *bnad, struct bna_tx *tx);
-
 	struct bfa_msgq_cmd_entry msgq_cmd;
 	union {
 		struct bfi_enet_tx_cfg_req	cfg_req;
-- 
2.3.6
