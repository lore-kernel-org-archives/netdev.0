From: Jing Huang <huangj@brocade.com>
Subject: [PATCH 3/7] bna: ioc cleanups
Date: Mon, 26 Mar 2012 12:39:01 -0700
Message-ID: <1332790741-9965-1-git-send-email-huangj@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Jing Huang <huangj@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:58096 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754494Ab2CZTjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 15:39:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove irrelevant code. Change to start Hearbeat failure moniter after IOC
become operational.

Signed-off-by: Jing Huang <huangj@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bfa_ioc.c |   11 +----------
 1 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index 7a3e79c..0b640fa 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -70,7 +70,6 @@ static void bfa_ioc_reset(struct bfa_ioc *ioc, bool force);
 static void bfa_ioc_mbox_poll(struct bfa_ioc *ioc);
 static void bfa_ioc_mbox_flush(struct bfa_ioc *ioc);
 static void bfa_ioc_recover(struct bfa_ioc *ioc);
-static void bfa_ioc_check_attr_wwns(struct bfa_ioc *ioc);
 static void bfa_ioc_event_notify(struct bfa_ioc *, enum bfa_ioc_event);
 static void bfa_ioc_disable_comp(struct bfa_ioc *ioc);
 static void bfa_ioc_lpu_stop(struct bfa_ioc *ioc);
@@ -346,8 +345,6 @@ bfa_ioc_sm_getattr(struct bfa_ioc *ioc, enum ioc_event event)
 	switch (event) {
 	case IOC_E_FWRSP_GETATTR:
 		del_timer(&ioc->ioc_timer);
-		bfa_ioc_check_attr_wwns(ioc);
-		bfa_ioc_hb_monitor(ioc);
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_op);
 		break;
 
@@ -380,6 +377,7 @@ bfa_ioc_sm_op_entry(struct bfa_ioc *ioc)
 {
 	ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_OK);
 	bfa_ioc_event_notify(ioc, BFA_IOC_E_ENABLED);
+	bfa_ioc_hb_monitor(ioc);
 }
 
 static void
@@ -2547,13 +2545,6 @@ bfa_ioc_recover(struct bfa_ioc *ioc)
 	bfa_fsm_send_event(ioc, IOC_E_HBFAIL);
 }
 
-static void
-bfa_ioc_check_attr_wwns(struct bfa_ioc *ioc)
-{
-	if (bfa_ioc_get_type(ioc) == BFA_IOC_TYPE_LL)
-		return;
-}
-
 /**
  * @dg hal_iocpf_pvt BFA IOC PF private functions
  * @{
-- 
1.6.5.2
