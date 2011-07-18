From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 27/45] bna: IOC Event Name Change
Date: Mon, 18 Jul 2011 01:22:47 -0700
Message-ID: <1310977385-5268-17-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37809 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754400Ab1GRIYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:24:23 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Changed event name IOC_E_PFAILED to IOC_E_PFFAILED

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index beb63f9..2dd19d2 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -108,7 +108,7 @@ enum ioc_event {
 	IOC_E_ENABLED		= 5,	/*!< f/w enabled		*/
 	IOC_E_FWRSP_GETATTR	= 6,	/*!< IOC get attribute response	*/
 	IOC_E_DISABLED		= 7,	/*!< f/w disabled		*/
-	IOC_E_PFAILED		= 8,	/*!< failure notice by iocpf sm	*/
+	IOC_E_PFFAILED		= 8,	/*!< failure notice by iocpf sm	*/
 	IOC_E_HBFAIL		= 9,	/*!< heartbeat failure		*/
 	IOC_E_HWERROR		= 10,	/*!< hardware error interrupt	*/
 	IOC_E_TIMEOUT		= 11,	/*!< timeout			*/
@@ -299,12 +299,12 @@ bfa_ioc_sm_enabling(struct bfa_ioc *ioc, enum ioc_event event)
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_getattr);
 		break;
 
-	case IOC_E_PFAILED:
+	case IOC_E_PFFAILED:
 		/* !!! fall through !!! */
 	case IOC_E_HWERROR:
 		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_fail);
-		if (event != IOC_E_PFAILED)
+		if (event != IOC_E_PFFAILED)
 			bfa_iocpf_initfail(ioc);
 		break;
 
@@ -354,14 +354,14 @@ bfa_ioc_sm_getattr(struct bfa_ioc *ioc, enum ioc_event event)
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_op);
 		break;
 
-	case IOC_E_PFAILED:
+	case IOC_E_PFFAILED:
 	case IOC_E_HWERROR:
 		del_timer(&ioc->ioc_timer);
 		/* fall through */
 	case IOC_E_TIMEOUT:
 		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_fail);
-		if (event != IOC_E_PFAILED)
+		if (event != IOC_E_PFFAILED)
 			bfa_iocpf_getattrfail(ioc);
 		break;
 
@@ -397,7 +397,7 @@ bfa_ioc_sm_op(struct bfa_ioc *ioc, enum ioc_event event)
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabling);
 		break;
 
-	case IOC_E_PFAILED:
+	case IOC_E_PFFAILED:
 	case IOC_E_HWERROR:
 		bfa_ioc_hb_stop(ioc);
 		/* !!! fall through !!! */
@@ -409,7 +409,7 @@ bfa_ioc_sm_op(struct bfa_ioc *ioc, enum ioc_event event)
 
 		bfa_ioc_fail_notify(ioc);
 
-		if (event != IOC_E_PFAILED)
+		if (event != IOC_E_PFFAILED)
 			bfa_iocpf_fail(ioc);
 		break;
 
@@ -501,14 +501,14 @@ bfa_ioc_sm_fail_retry(struct bfa_ioc *ioc, enum ioc_event event)
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_getattr);
 		break;
 
-	case IOC_E_PFAILED:
+	case IOC_E_PFFAILED:
 	case IOC_E_HWERROR:
 		/**
 		 * Initialization retry failed.
 		 */
 		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_fail);
-		if (event != IOC_E_PFAILED)
+		if (event != IOC_E_PFFAILED)
 			bfa_iocpf_initfail(ioc);
 		break;
 
@@ -1722,7 +1722,7 @@ bfa_ioc_pf_disabled(struct bfa_ioc *ioc)
 static void
 bfa_ioc_pf_failed(struct bfa_ioc *ioc)
 {
-	bfa_fsm_send_event(ioc, IOC_E_PFAILED);
+	bfa_fsm_send_event(ioc, IOC_E_PFFAILED);
 }
 
 static void
-- 
1.7.1

