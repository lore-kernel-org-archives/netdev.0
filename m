From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.26] gianfar: Fix a bug where the pointer never moves for dma_unmap...
Date: Wed,  7 May 2008 13:20:55 -0500
Message-ID: <1210184455-28477-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:61254 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755001AbYEGSU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 14:20:58 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m47IKuni014784
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 11:20:56 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id m47IKtZ6003776
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 13:20:55 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The loop that unmaps all of the TX Buffer Descriptors never actually
moves the txbd pointer, so we were just repeatedly unmapping the first one.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 6f22f06..25bdd08 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -635,6 +635,8 @@ static void free_skb_resources(struct gfar_private *priv)
 			dev_kfree_skb_any(priv->tx_skbuff[i]);
 			priv->tx_skbuff[i] = NULL;
 		}
+
+		txbdp++;
 	}
 
 	kfree(priv->tx_skbuff);
-- 
1.5.4.GIT

