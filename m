From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v2 7/9] b44: activate PHY when MAC is off
Date: Thu, 19 Dec 2013 02:28:44 +0100
Message-ID: <1387416526-7394-8-git-send-email-hauke@hauke-m.de>
References: <1387416526-7394-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	f.fainelli@gmail.com, Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:44357 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751963Ab3LSBaK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 20:30:10 -0500
In-Reply-To: <1387416526-7394-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this patch we can not access the PHY when the MAC is switched
off. This PHY access is needed to configure the switch, which is done
through PHY registers.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/b44.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 7b1e71d..d17561b 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -1360,7 +1360,10 @@ static void b44_halt(struct b44 *bp)
 	bw32(bp, B44_MAC_CTRL, MAC_CTRL_PHY_PDOWN);
 	/* now reset the chip, but without enabling the MAC&PHY
 	 * part of it. This has to be done _after_ we shut down the PHY */
-	b44_chip_reset(bp, B44_CHIP_RESET_PARTIAL);
+	if (bp->flags & B44_FLAG_EXTERNAL_PHY)
+		b44_chip_reset(bp, B44_CHIP_RESET_FULL);
+	else
+		b44_chip_reset(bp, B44_CHIP_RESET_PARTIAL);
 }
 
 /* bp->lock is held. */
-- 
1.7.10.4
