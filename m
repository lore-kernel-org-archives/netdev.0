From: frank.blaschka@de.ibm.com
Subject: [patch 1/2] [PATCH] drivers/s390/net: Drop memory allocation cast
Date: Mon, 17 May 2010 09:15:13 +0200
Message-ID: <20100517071552.120190000@de.ibm.com>
References: <20100517071512.118564000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Julia Lawall <julia@diku.dk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.17.167]:48386 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159Ab0EQHPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 03:15:54 -0400
Content-Disposition: inline; filename=610-drop-alloc-cast.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Drop cast on the result of kmalloc and similar functions.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
type T;
@@

- (T *)
  (\(kmalloc\|kzalloc\|kcalloc\|kmem_cache_alloc\|kmem_cache_zalloc\|
   kmem_cache_alloc_node\|kmalloc_node\|kzalloc_node\)(...))
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/ctcm_main.c      |    6 ++----
 drivers/s390/net/ctcm_mpc.c       |    6 ++----
 drivers/s390/net/lcs.c            |    3 +--
 drivers/s390/net/qeth_core_main.c |    2 +-
 4 files changed, 6 insertions(+), 11 deletions(-)

--- a/drivers/s390/net/ctcm_main.c
+++ b/drivers/s390/net/ctcm_main.c
@@ -1364,8 +1364,7 @@ static int add_channel(struct ccw_device
 
 	ch->protocol = priv->protocol;
 	if (IS_MPC(priv)) {
-		ch->discontact_th = (struct th_header *)
-				kzalloc(TH_HEADER_LENGTH, gfp_type());
+		ch->discontact_th = kzalloc(TH_HEADER_LENGTH, gfp_type());
 		if (ch->discontact_th == NULL)
 					goto nomem_return;
 
@@ -1379,8 +1378,7 @@ static int add_channel(struct ccw_device
 	} else
 		ccw_num = 8;
 
-	ch->ccw = (struct ccw1 *)
-		kzalloc(ccw_num * sizeof(struct ccw1), GFP_KERNEL | GFP_DMA);
+	ch->ccw = kzalloc(ccw_num * sizeof(struct ccw1), GFP_KERNEL | GFP_DMA);
 	if (ch->ccw == NULL)
 					goto nomem_return;
 
--- a/drivers/s390/net/ctcm_mpc.c
+++ b/drivers/s390/net/ctcm_mpc.c
@@ -669,8 +669,7 @@ static void ctcmpc_send_sweep_resp(struc
 				goto done;
 	}
 
-	header = (struct th_sweep *)
-			kmalloc(sizeof(struct th_sweep), gfp_type());
+	header = kmalloc(sizeof(struct th_sweep), gfp_type());
 
 	if (!header) {
 		dev_kfree_skb_any(sweep_skb);
@@ -1191,8 +1190,7 @@ static void ctcmpc_unpack_skb(struct cha
 			skb_pull(pskb, new_len); /* point to next PDU */
 		}
 	} else {
-		mpcginfo = (struct mpcg_info *)
-				kmalloc(sizeof(struct mpcg_info), gfp_type());
+		mpcginfo = kmalloc(sizeof(struct mpcg_info), gfp_type());
 		if (mpcginfo == NULL)
 					goto done;
 
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -1238,8 +1238,7 @@ lcs_set_mc_addresses(struct lcs_card *ca
 		ipm = lcs_check_addr_entry(card, im4, buf);
 		if (ipm != NULL)
 			continue;	/* Address already in list. */
-		ipm = (struct lcs_ipm_list *)
-			kzalloc(sizeof(struct lcs_ipm_list), GFP_ATOMIC);
+		ipm = kzalloc(sizeof(struct lcs_ipm_list), GFP_ATOMIC);
 		if (ipm == NULL) {
 			pr_info("Not enough memory to add"
 				" new multicast entry!\n");
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -606,7 +606,7 @@ static int qeth_setup_channel(struct qet
 
 	QETH_DBF_TEXT(SETUP, 2, "setupch");
 	for (cnt = 0; cnt < QETH_CMD_BUFFER_NO; cnt++) {
-		channel->iob[cnt].data = (char *)
+		channel->iob[cnt].data =
 			kmalloc(QETH_BUFSIZE, GFP_DMA|GFP_KERNEL);
 		if (channel->iob[cnt].data == NULL)
 			break;

