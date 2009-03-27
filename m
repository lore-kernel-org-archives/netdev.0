From: Li Yang <leoli@freescale.com>
Subject: [PATCH] gianfar: only check headroom when FCB is needed
Date: Fri, 27 Mar 2009 16:01:30 +0800
Message-ID: <1238140890-26058-1-git-send-email-leoli@freescale.com>
References: <2a27d3730903262126v1a0282a5u6c8ee234dff8708d@mail.gmail.com>
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	Li Yang <leoli@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:40850 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbZC0IQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 04:16:58 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n2R8GuMv024152
	for <netdev@vger.kernel.org>; Fri, 27 Mar 2009 01:16:56 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n2R8Gsch021660
	for <netdev@vger.kernel.org>; Fri, 27 Mar 2009 03:16:55 -0500 (CDT)
In-Reply-To: <2a27d3730903262126v1a0282a5u6c8ee234dff8708d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/gianfar.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 14f9b5e..6e28088 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1277,8 +1277,10 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	base = priv->tx_bd_base;
 
-	/* make space for additional header */
-	if (skb_headroom(skb) < GMAC_FCB_LEN) {
+	/* make space for additional header when fcb is needed */
+	if (((skb->ip_summed == CHECKSUM_PARTIAL) ||
+			(priv->vlgrp && vlan_tx_tag_present(skb))) &&
+			(skb_headroom(skb) < GMAC_FCB_LEN)) {
 		struct sk_buff *skb_new;
 
 		skb_new = skb_realloc_headroom(skb, GMAC_FCB_LEN);
-- 
1.5.4

