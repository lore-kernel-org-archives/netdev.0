From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 07/10] bna: IOC Event Name Change
Date: Fri, 22 Jul 2011 11:07:46 -0700
Message-ID: <1311358069-32067-8-git-send-email-rmody@brocade.com>
References: <1311358069-32067-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37613 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754575Ab1GVSIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 14:08:39 -0400
In-Reply-To: <1311358069-32067-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Changed event name IOC_E_PFAILED to IOC_E_PFFAILED

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index 889039c..da56c2f 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -108,7 +108,7 @@ enum ioc_event {
 	IOC_E_FWRSP_GETATTR	= 6,	/*!< IOC get attribute response	*/
 	IOC_E_DISABLED		= 7,	/*!< f/w disabled		*/
 	IOC_E_INITFAILED	= 8,	/*!< failure notice by iocpf sm	*/
-	IOC_E_PFAILED		= 9,	/*!< failure notice by iocpf sm	*/
+	IOC_E_PFFAILED		= 9,	/*!< failure notice by iocpf sm	*/
 	IOC_E_HBFAIL		= 10,	/*!< heartbeat failure		*/
 	IOC_E_HWERROR		= 11,	/*!< hardware error interrupt	*/
 	IOC_E_TIMEOUT		= 12,	/*!< timeout			*/
@@ -295,12 +295,12 @@ bfa_ioc_sm_enabling(struct bfa_ioc *ioc, enum ioc_event event)
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_getattr);
 		break;
 
-	case IOC_E_PFAILED:
+	case IOC_E_PFFAILED:
 		/* !!! fall through !!! */
 	case IOC_E_HWERROR:
 		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_fail_retry);
-		if (event != IOC_E_PFAILED)
+		if (event != IOC_E_PFFAILED)
 			bfa_iocpf_initfail(ioc);
 		break;
 
@@ -345,14 +345,14 @@ bfa_ioc_sm_getattr(struct bfa_ioc *ioc, enum ioc_event event)
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_op);
 		break;
 
-	case IOC_E_PFAILED:
+	case IOC_E_PFFAILED:
 	case IOC_E_HWERROR:
 		del_timer(&ioc->ioc_timer);
 		/* fall through */
 	case IOC_E_TIMEOUT:
 		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_fail_retry);
-		if (event != IOC_E_PFAILED)
+		if (event != IOC_E_PFFAILED)
 			bfa_iocpf_getattrfail(ioc);
 		break;
 
@@ -388,7 +388,7 @@ bfa_ioc_sm_op(struct bfa_ioc *ioc, enum ioc_event event)
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabling);
 		break;
 
-	case IOC_E_PFAILED:
+	case IOC_E_PFFAILED:
 	case IOC_E_HWERROR:
 		bfa_ioc_hb_stop(ioc);
 		/* !!! fall through !!! */
@@ -399,7 +399,7 @@ bfa_ioc_sm_op(struct bfa_ioc *ioc, enum ioc_event event)
 		else
 			bfa_fsm_set_state(ioc, bfa_ioc_sm_fail);
 
-		if (event != IOC_E_PFAILED)
+		if (event != IOC_E_PFFAILED)
 			bfa_iocpf_fail(ioc);
 		break;
 
@@ -486,13 +486,13 @@ bfa_ioc_sm_fail_retry(struct bfa_ioc *ioc, enum ioc_event event)
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_getattr);
 		break;
 
-	case IOC_E_PFAILED:
+	case IOC_E_PFFAILED:
 	case IOC_E_HWERROR:
 		/**
 		 * Initialization retry failed.
 		 */
 		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
-		if (event != IOC_E_PFAILED)
+		if (event != IOC_E_PFFAILED)
 			bfa_iocpf_initfail(ioc);
 		break;
 
@@ -1685,7 +1685,7 @@ bfa_ioc_pf_initfailed(struct bfa_ioc *ioc)
 static void
 bfa_ioc_pf_failed(struct bfa_ioc *ioc)
 {
-	bfa_fsm_send_event(ioc, IOC_E_PFAILED);
+	bfa_fsm_send_event(ioc, IOC_E_PFFAILED);
 }
 
 static void
-- 
1.7.1

