From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 v3 1/5] gianfar: Fix packet drop when out of memory
Date: Wed, 17 Dec 2008 15:42:51 -0600
Message-ID: <1229550175-15600-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:59366 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782AbYLQVm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:42:57 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBHLguLN001215
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 14:42:57 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id mBHLguiA027780
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 15:42:56 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch which fixed gianfar so it drops packets when it runs out
of memory left in the code which frees the skb when it drops packets.
Change the code so that we only free the skb if the new skb was successfully
created.

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

