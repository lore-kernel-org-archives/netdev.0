From: jon@ringle.org
Subject: [PATCH net-next] net: encx24j600: Fix mask to update LED configuration
Date: Thu, 22 Oct 2015 15:09:04 -0400
Message-ID: <1445540944-13894-1-git-send-email-jon@ringle.org>
Cc: Jon Ringle <jringle@gridpoint.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:36501 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070AbbJVTJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 15:09:08 -0400
Received: by qkca6 with SMTP id a6so58528258qkc.3
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 12:09:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Ringle <jringle@gridpoint.com>

This fixes the mask used to update the LED configuration so that it clears
the necessary bits as well as setting the bits according to the mask.
Also reverse the LED configuration to show the Link state + collisions in
LEDA and the Link state + TX/RX events in LEDB.

Signed-off-by: Jon Ringle <jringle@gridpoint.com>
---
 drivers/net/ethernet/microchip/encx24j600.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/microchip/encx24j600.c b/drivers/net/ethernet/microchip/encx24j600.c
index e1329d9..bf08ce2 100644
--- a/drivers/net/ethernet/microchip/encx24j600.c
+++ b/drivers/net/ethernet/microchip/encx24j600.c
@@ -617,10 +617,10 @@ static int encx24j600_hw_init(struct encx24j600_priv *priv)
 		   (eidled & REVID_MASK) >> REVID_SHIFT);
 
 	/* PHY Leds: link status,
-	 * LEDA: Link + transmit/receive events
-	 * LEDB: Link State + colision events
+	 * LEDA: Link State + collision events
+	 * LEDB: Link State + transmit/receive events
 	 */
-	encx24j600_update_reg(priv, EIDLED, 0xbc00, 0xbc00);
+	encx24j600_update_reg(priv, EIDLED, 0xff00, 0xcb00);
 
 	/* Loopback disabled */
 	encx24j600_write_reg(priv, MACON1, 0x9);
-- 
2.4.1
