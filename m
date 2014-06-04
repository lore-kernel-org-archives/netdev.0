From: Andrew Ruder <andrew.ruder@elecsyscorp.com>
Subject: [PATCH 4/6] dm9000: remove redundant ISR status clear
Date: Wed,  4 Jun 2014 17:28:47 -0500
Message-ID: <64216833c030bd0a5c26c5772511a677de15b11e.1401920694.git.andrew.ruder@elecsyscorp.com>
References: <cover.1401920320.git.andrew.ruder@elecsyscorp.com>
Cc: Andrew Ruder <andrew.ruder@elecsyscorp.com>,
	Joseph CHANG <josright123@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from new1-smtp.messagingengine.com ([66.111.4.221]:40765 "EHLO
	new1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751717AbaFDWh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 18:37:56 -0400
Received: from compute4.internal (compute4.nyi.mail.srv.osa [10.202.2.44])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 5E1404AF
	for <netdev@vger.kernel.org>; Wed,  4 Jun 2014 18:29:15 -0400 (EDT)
In-Reply-To: <cover.1401920320.git.andrew.ruder@elecsyscorp.com>
In-Reply-To: <cover.1401920694.git.andrew.ruder@elecsyscorp.com>
References: <cover.1401920694.git.andrew.ruder@elecsyscorp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since dm9000_interrupt() is already reading/clearing every set bit in
DM9000_ISR, this additional clear in dm9000_rx() (which is only called
by dm9000_interrupt()) is unnecessary and can be removed.

Signed-off-by: Andrew Ruder <andrew.ruder@elecsyscorp.com>
---
 drivers/net/ethernet/davicom/dm9000.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index c508a33..d1a5b2f 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1105,7 +1105,6 @@ dm9000_rx(struct net_device *dev)
 		if (rxbyte & DM9000_PKT_ERR) {
 			dev_warn(db->dev, "status check fail: %d\n", rxbyte);
 			iow(db, DM9000_RCR, 0x00);	/* Stop Device */
-			iow(db, DM9000_ISR, IMR_PAR);	/* Stop INT request */
 			return;
 		}
 
-- 
1.9.0.rc3.12.gbc97e2d
