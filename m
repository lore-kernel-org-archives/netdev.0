From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] ieee802154: mrf24j40: fix incorrect mask in mrf24j40_stop
Date: Tue, 31 Oct 2017 01:31:27 -0500
Message-ID: <20171031063127.GA6032@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Alan Ott <alan@signal11.us>,
        Alexander Aring <alex.aring@gmail.com>,
        Stefan Schmidt <stefan@osg.samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway23.websitewelcome.com ([192.185.49.177]:42224 "EHLO
        gateway23.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751896AbdJaGci (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 02:32:38 -0400
Received: from cm11.websitewelcome.com (cm11.websitewelcome.com [100.42.49.5])
        by gateway23.websitewelcome.com (Postfix) with ESMTP id 62092157A2
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 01:31:33 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that this is a copy/paste error and the proper bit masking is:
BIT_TXNIE | BIT_RXIE

This issue was detected with the help of Coccinelle.

Reported-by: Julia Lawall <julia.lawall@lip6.fr>
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
Fixes: 7d840545e5b9 ("mrf24j40: replace magic numbers")
---
 drivers/net/ieee802154/mrf24j40.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index ee7084b..cf4788d 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -635,7 +635,7 @@ static void mrf24j40_stop(struct ieee802154_hw *hw)
 
 	/* Set TXNIE and RXIE. Disable Interrupts */
 	regmap_update_bits(devrec->regmap_short, REG_INTCON,
-			   BIT_TXNIE | BIT_TXNIE, BIT_TXNIE | BIT_TXNIE);
+			   BIT_TXNIE | BIT_RXIE, BIT_TXNIE | BIT_RXIE);
 }
 
 static int mrf24j40_set_channel(struct ieee802154_hw *hw, u8 page, u8 channel)
-- 
2.7.4
