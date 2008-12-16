From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 08/14] gianfar: Remove unused gfar_add_fcb() function parameter
Date: Tue, 16 Dec 2008 17:21:01 -0600
Message-ID: <1229469667-25002-9-git-send-email-afleming@freescale.com>
References: <1229469667-25002-1-git-send-email-afleming@freescale.com>
 <1229469667-25002-2-git-send-email-afleming@freescale.com>
 <1229469667-25002-3-git-send-email-afleming@freescale.com>
 <1229469667-25002-4-git-send-email-afleming@freescale.com>
 <1229469667-25002-5-git-send-email-afleming@freescale.com>
 <1229469667-25002-6-git-send-email-afleming@freescale.com>
 <1229469667-25002-7-git-send-email-afleming@freescale.com>
 <1229469667-25002-8-git-send-email-afleming@freescale.com>
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org,
	Haruki Dai <Dai.Haruki@freescale.com>,
	Dai Haruki <dai.haruki@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:39703 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753748AbYLPXVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:21:23 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBGNLAQP013562
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 16:21:10 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id mBGNL9pH017609
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:21:09 -0600 (CST)
In-Reply-To: <1229469667-25002-8-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haruki Dai <Dai.Haruki@freescale.com>

- Also, use cacheable_memzero instead of memset for performance reasons.

Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
Acked-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 21d7acf..6c0e0a3 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1166,11 +1166,11 @@ static int gfar_enet_open(struct net_device *dev)
 	return err;
 }
 
-static inline struct txfcb *gfar_add_fcb(struct sk_buff *skb, struct txbd8 *bdp)
+static inline struct txfcb *gfar_add_fcb(struct sk_buff *skb)
 {
 	struct txfcb *fcb = (struct txfcb *)skb_push (skb, GMAC_FCB_LEN);
 
-	memset(fcb, 0, GMAC_FCB_LEN);
+	cacheable_memzero(fcb, GMAC_FCB_LEN);
 
 	return fcb;
 }
@@ -1233,14 +1233,14 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Set up checksumming */
 	if (CHECKSUM_PARTIAL == skb->ip_summed) {
-		fcb = gfar_add_fcb(skb, txbdp);
+		fcb = gfar_add_fcb(skb);
 		status |= TXBD_TOE;
 		gfar_tx_checksum(skb, fcb);
 	}
 
 	if (priv->vlgrp && vlan_tx_tag_present(skb)) {
 		if (unlikely(NULL == fcb)) {
-			fcb = gfar_add_fcb(skb, txbdp);
+			fcb = gfar_add_fcb(skb);
 			status |= TXBD_TOE;
 		}
 
-- 
1.5.4.GIT

