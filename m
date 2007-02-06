From: Li Yang <leoli@freescale.com>
Subject: [PATCH 2/4] ucc_geth: Switch kmalloc to kzalloc and clean some redundant
 kmalloc casts
Date: Tue, 06 Feb 2007 19:31:38 +0800
Message-ID: <45C8671A.9040002@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:33099 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbXBFLaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 06:30:24 -0500
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id l16BUOWk005057
	for <netdev@vger.kernel.org>; Tue, 6 Feb 2007 04:30:24 -0700 (MST)
Received: from zch01exm20.fsl.freescale.net (zch01exm20.ap.freescale.net [10.192.129.204])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id l16BUMQu020611
	for <netdev@vger.kernel.org>; Tue, 6 Feb 2007 05:30:23 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ahmed S. Darwish <darwish.07@gmail.com>

Switch kmalloc to kzalloc and clean some redundant kmalloc
casts.

Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/ucc_geth.c |   21 ++++++++-------------
 1 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 722a89f..50b1fe9 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2927,10 +2927,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* Init Tx bds */
 	for (j = 0; j < ug_info->numQueuesTx; j++) {
 		/* Setup the skbuff rings */
-		ugeth->tx_skbuff[j] =
-		    (struct sk_buff **)kmalloc(sizeof(struct sk_buff *) *
-					       ugeth->ug_info->bdRingLenTx[j],
-					       GFP_KERNEL);
+		ugeth->tx_skbuff[j] = kmalloc(sizeof(struct sk_buff *) *
+					      ugeth->ug_info->bdRingLenTx[j],
+					      GFP_KERNEL);
 
 		if (ugeth->tx_skbuff[j] == NULL) {
 			ugeth_err("%s: Could not allocate tx_skbuff",
@@ -2959,10 +2958,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* Init Rx bds */
 	for (j = 0; j < ug_info->numQueuesRx; j++) {
 		/* Setup the skbuff rings */
-		ugeth->rx_skbuff[j] =
-		    (struct sk_buff **)kmalloc(sizeof(struct sk_buff *) *
-					       ugeth->ug_info->bdRingLenRx[j],
-					       GFP_KERNEL);
+		ugeth->rx_skbuff[j] = kmalloc(sizeof(struct sk_buff *) *
+					      ugeth->ug_info->bdRingLenRx[j],
+					      GFP_KERNEL);
 
 		if (ugeth->rx_skbuff[j] == NULL) {
 			ugeth_err("%s: Could not allocate rx_skbuff",
@@ -3434,19 +3432,16 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	 * resource.
 	 * This shadow structure keeps a copy of what was done so that the
 	 * allocated resources can be released when the channel is freed.
+	 * *p_init_enet_param_shadow is zeroed by kzalloc
 	 */
 	if (!(ugeth->p_init_enet_param_shadow =
-	     (struct ucc_geth_init_pram *) kmalloc(sizeof(struct ucc_geth_init_pram),
-					      GFP_KERNEL))) {
+	      kzalloc(sizeof(struct ucc_geth_init_pram), GFP_KERNEL))) {
 		ugeth_err
 		    ("%s: Can not allocate memory for"
 			" p_UccInitEnetParamShadows.", __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
-	/* Zero out *p_init_enet_param_shadow */
-	memset((char *)ugeth->p_init_enet_param_shadow,
-	       0, sizeof(struct ucc_geth_init_pram));
 
 	/* Fill shadow InitEnet command parameter structure */
 

