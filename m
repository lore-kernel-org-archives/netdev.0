From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: bcm_sf2: fix 64-bits register reads
Date: Thu, 19 Feb 2015 11:09:27 -0800
Message-ID: <1424372967-27938-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:45229 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbbBSTJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 14:09:46 -0500
Received: by pdjz10 with SMTP id z10so1711667pdj.12
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 11:09:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reading 64-bits register was not working because we inverted the steps
between reading the lower 32-bits of the register and reading the upper
32-bits. Swapping these operations is how the HW guarantees that 64-bits
reads are latched correctly. We only have a handful of 64-bits registers
for now, mostly MIB counters, so the imapct is low.

Fixes: 246d7f773c13 ("net: dsa: add Broadcom SF2 switch driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index ee9f650d5026..7b7053d3c5fa 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -105,8 +105,8 @@ static inline u64 name##_readq(struct bcm_sf2_priv *priv, u32 off)	\
 {									\
 	u32 indir, dir;							\
 	spin_lock(&priv->indir_lock);					\
-	indir = reg_readl(priv, REG_DIR_DATA_READ);			\
 	dir = __raw_readl(priv->name + off);				\
+	indir = reg_readl(priv, REG_DIR_DATA_READ);			\
 	spin_unlock(&priv->indir_lock);					\
 	return (u64)indir << 32 | dir;					\
 }									\
-- 
2.1.0
