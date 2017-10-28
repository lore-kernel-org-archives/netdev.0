From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH] net: systemport: Correct IPG length settings
Date: Fri, 27 Oct 2017 17:30:00 -0700
Message-ID: <20171028003000.6114-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:56248 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbdJ1AaE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 20:30:04 -0400
Received: by mail-qt0-f193.google.com with SMTP id v41so10393352qtv.12
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 17:30:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to a documentation mistake, the IPG length was set to 0x12 while it
should have been 12 (decimal). This would affect short packet (64B
typically) performance since the IPG was bigger than necessary.

Fixes: 44a4524c54af ("net: systemport: Add support for SYSTEMPORT Lite")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 83eec9a8c275..7c51332eb3d9 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1811,11 +1811,13 @@ static inline void gib_set_pad_extension(struct bcm_sysport_priv *priv)
 {
 	u32 __maybe_unused reg;
 
-	/* Include Broadcom tag in pad extension */
+	/* Include Broadcom tag in pad extension and fix up IPG_LENGTH */
 	if (netdev_uses_dsa(priv->netdev)) {
 		reg = gib_readl(priv, GIB_CONTROL);
 		reg &= ~(GIB_PAD_EXTENSION_MASK << GIB_PAD_EXTENSION_SHIFT);
 		reg |= ENET_BRCM_TAG_LEN << GIB_PAD_EXTENSION_SHIFT;
+		reg &= ~(GIB_IPG_LEN_MASK << GIB_IPG_LEN_SHIFT);
+		reg |= 12 << GIB_IPG_LEN_SHIFT;
 		gib_writel(priv, reg, GIB_CONTROL);
 	}
 }
-- 
2.9.3
