From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 v2 1/5] gianfar: Fix skb allocation error
Date: Wed, 17 Dec 2008 12:52:57 -0600
Message-ID: <1229539981-14041-2-git-send-email-afleming@freescale.com>
References: <1229539981-14041-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:58732 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbYLQSxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 13:53:18 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBHIr2W9011176
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 11:53:13 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id mBHIr2aP015942
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 12:53:02 -0600 (CST)
In-Reply-To: <1229539981-14041-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't want to unmap the skb if we've decided to use the old one, so we only
unmap it if we're *not* using the old one.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 3e611a6..a6efabc 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1732,8 +1732,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 
 			if (unlikely(!newskb))
 				newskb = skb;
-
-			if (skb)
+			else if (skb)
 				dev_kfree_skb_any(skb);
 		} else {
 			/* Increment the number of packets */
-- 
1.5.4.GIT

