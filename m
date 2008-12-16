From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 02/14] gianfar: Fix skb allocation error
Date: Tue, 16 Dec 2008 17:20:55 -0600
Message-ID: <1229469667-25002-3-git-send-email-afleming@freescale.com>
References: <1229469667-25002-1-git-send-email-afleming@freescale.com>
 <1229469667-25002-2-git-send-email-afleming@freescale.com>
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:39668 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312AbYLPXVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:21:20 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBGNL9R1013519
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 16:21:09 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id mBGNL80U017592
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:21:08 -0600 (CST)
In-Reply-To: <1229469667-25002-2-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't want to unmap the skb if we've decided to use the old one, so we only
unmap it if we're *not* using the old one.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 6ceff8d..7040a17 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1659,8 +1659,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 
 			if (unlikely(!newskb))
 				newskb = skb;
-
-			if (skb) {
+			else if (skb) {
 				dma_unmap_single(&priv->dev->dev,
 						bdp->bufPtr,
 						priv->rx_buffer_size,
-- 
1.5.4.GIT

