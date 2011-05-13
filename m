From: frank.blaschka@de.ibm.com
Subject: [patch 6/9] [PATCH] ctcm: get rid of compile warning
Date: Fri, 13 May 2011 06:45:06 +0200
Message-ID: <20110513044547.967841361@de.ibm.com>
References: <20110513044500.190198403@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:47221 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294Ab1EMEpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 00:45:50 -0400
Content-Disposition: inline; filename=605-ctcm-compile-warning.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

-Wunused-but-set-variable generates compile warnings. The affected
variables are removed.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 drivers/s390/net/ctcm_main.c |    2 --
 drivers/s390/net/ctcm_mpc.c  |   13 ++++---------
 2 files changed, 4 insertions(+), 11 deletions(-)
diff -urpN linux-2.6/drivers/s390/net/ctcm_main.c linux-2.6-patched/drivers/s390/net/ctcm_main.c
--- linux-2.6/drivers/s390/net/ctcm_main.c	2011-05-10 09:14:06.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/ctcm_main.c	2011-05-10 09:14:26.000000000 +0200
@@ -672,7 +672,6 @@ static int ctcmpc_transmit_skb(struct ch
 	int ccw_idx;
 	unsigned long hi;
 	unsigned long saveflags = 0;	/* avoids compiler warning */
-	__u16 block_len;
 
 	CTCM_PR_DEBUG("Enter %s: %s, cp=%i ch=0x%p id=%s state=%s\n",
 			__func__, dev->name, smp_processor_id(), ch,
@@ -719,7 +718,6 @@ static int ctcmpc_transmit_skb(struct ch
 	 */
 	atomic_inc(&skb->users);
 
-	block_len = skb->len + TH_HEADER_LENGTH + PDU_HEADER_LENGTH;
 	/*
 	 * IDAL support in CTCM is broken, so we have to
 	 * care about skb's above 2G ourselves.
diff -urpN linux-2.6/drivers/s390/net/ctcm_mpc.c linux-2.6-patched/drivers/s390/net/ctcm_mpc.c
--- linux-2.6/drivers/s390/net/ctcm_mpc.c	2011-03-15 02:20:32.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/ctcm_mpc.c	2011-05-10 09:14:26.000000000 +0200
@@ -653,7 +653,6 @@ static void ctcmpc_send_sweep_resp(struc
 	struct net_device *dev = rch->netdev;
 	struct ctcm_priv *priv = dev->ml_priv;
 	struct mpc_group *grp = priv->mpcg;
-	int rc = 0;
 	struct th_sweep *header;
 	struct sk_buff *sweep_skb;
 	struct channel *ch  = priv->channel[CTCM_WRITE];
@@ -665,16 +664,14 @@ static void ctcmpc_send_sweep_resp(struc
 		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
 			"%s(%s): sweep_skb allocation ERROR\n",
 			CTCM_FUNTAIL, rch->id);
-		rc = -ENOMEM;
-				goto done;
+		goto done;
 	}
 
 	header = kmalloc(sizeof(struct th_sweep), gfp_type());
 
 	if (!header) {
 		dev_kfree_skb_any(sweep_skb);
-		rc = -ENOMEM;
-				goto done;
+		goto done;
 	}
 
 	header->th.th_seg	= 0x00 ;
@@ -1370,8 +1367,7 @@ static void mpc_action_go_inop(fsm_insta
 	struct net_device  *dev = arg;
 	struct ctcm_priv    *priv;
 	struct mpc_group *grp;
-	int rc = 0;
-	struct channel *wch, *rch;
+	struct channel *wch;
 
 	BUG_ON(dev == NULL);
 	CTCM_PR_DEBUG("Enter %s: %s\n",	__func__, dev->name);
@@ -1396,7 +1392,6 @@ static void mpc_action_go_inop(fsm_insta
 		fsm_deltimer(&priv->restart_timer);
 
 	wch = priv->channel[CTCM_WRITE];
-	rch = priv->channel[CTCM_READ];
 
 	switch (grp->saved_state) {
 	case MPCG_STATE_RESET:
@@ -1435,7 +1430,7 @@ static void mpc_action_go_inop(fsm_insta
 
 	if (grp->send_qllc_disc == 1) {
 		grp->send_qllc_disc = 0;
-		rc = mpc_send_qllc_discontact(dev);
+		mpc_send_qllc_discontact(dev);
 	}
 
 	/* DO NOT issue DEV_EVENT_STOP directly out of this code */

