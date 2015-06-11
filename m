From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next v2 07/19] bna: remove pause_cbfn from struct bna_enet
Date: Thu, 11 Jun 2015 15:52:19 +0200
Message-ID: <1434030751-28835-8-git-send-email-ivecera@redhat.com>
References: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46598 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751205AbbFKNwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 09:52:14 -0400
In-Reply-To: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bna_enet.c  | 15 ---------------
 drivers/net/ethernet/brocade/bna/bna_types.h |  3 ---
 2 files changed, 18 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna_enet.c b/drivers/net/ethernet/brocade/bna/bna_enet.c
index b8de17b..dc9f73b 100644
--- a/drivers/net/ethernet/brocade/bna/bna_enet.c
+++ b/drivers/net/ethernet/brocade/bna/bna_enet.c
@@ -884,16 +884,6 @@ do {									\
 	}								\
 } while (0)
 
-#define call_enet_pause_cbfn(enet)					\
-do {									\
-	if ((enet)->pause_cbfn) {					\
-		void (*cbfn)(struct bnad *);				\
-		cbfn = (enet)->pause_cbfn;				\
-		(enet)->pause_cbfn = NULL;				\
-		cbfn((enet)->bna->bnad);				\
-	}								\
-} while (0)
-
 #define call_enet_mtu_cbfn(enet)					\
 do {									\
 	if ((enet)->mtu_cbfn) {						\
@@ -925,7 +915,6 @@ bfa_fsm_state_decl(bna_enet, chld_stop_wait, struct bna_enet,
 static void
 bna_enet_sm_stopped_entry(struct bna_enet *enet)
 {
-	call_enet_pause_cbfn(enet);
 	call_enet_mtu_cbfn(enet);
 	call_enet_stop_cbfn(enet);
 }
@@ -947,7 +936,6 @@ bna_enet_sm_stopped(struct bna_enet *enet, enum bna_enet_event event)
 		break;
 
 	case ENET_E_PAUSE_CFG:
-		call_enet_pause_cbfn(enet);
 		break;
 
 	case ENET_E_MTU_CFG:
@@ -1039,7 +1027,6 @@ bna_enet_sm_started_entry(struct bna_enet *enet)
 	 * NOTE: Do not call bna_enet_chld_start() here, since it will be
 	 * inadvertently called during cfg_wait->started transition as well
 	 */
-	call_enet_pause_cbfn(enet);
 	call_enet_mtu_cbfn(enet);
 }
 
@@ -1211,8 +1198,6 @@ bna_enet_init(struct bna_enet *enet, struct bna *bna)
 	enet->stop_cbfn = NULL;
 	enet->stop_cbarg = NULL;
 
-	enet->pause_cbfn = NULL;
-
 	enet->mtu_cbfn = NULL;
 
 	bfa_fsm_set_state(enet, bna_enet_sm_stopped);
diff --git a/drivers/net/ethernet/brocade/bna/bna_types.h b/drivers/net/ethernet/brocade/bna/bna_types.h
index d0a7a56..a50ee99 100644
--- a/drivers/net/ethernet/brocade/bna/bna_types.h
+++ b/drivers/net/ethernet/brocade/bna/bna_types.h
@@ -362,9 +362,6 @@ struct bna_enet {
 	void (*stop_cbfn)(void *);
 	void			*stop_cbarg;
 
-	/* Callback for bna_enet_pause_config() */
-	void (*pause_cbfn)(struct bnad *);
-
 	/* Callback for bna_enet_mtu_set() */
 	void (*mtu_cbfn)(struct bnad *);
 
-- 
2.3.6
