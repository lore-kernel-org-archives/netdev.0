From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: bcmgenet: Do not return from void function
Date: Tue, 29 Aug 2017 21:48:51 -0700
Message-ID: <20170830044851.20348-1-f.fainelli@gmail.com>
Cc: davem@daveloft.net, opendmb@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:32923 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750762AbdH3Es4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 00:48:56 -0400
Received: by mail-oi0-f65.google.com with SMTP id t124so4738274oih.0
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 21:48:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A stray return was added in the macro bcmgenet_##name##_writel where it
should not, drop it.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Fixes: 69d2ea9c7989 ("net: bcmgenet: Use correct I/O accessors")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 2bfeaefcca0f..4c49d0b97748 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -684,7 +684,7 @@ static inline void bcmgenet_##name##_writel(struct bcmgenet_priv *priv,	\
 					u32 val, u32 off)		\
 {									\
 	if (IS_ENABLED(CONFIG_MIPS) && IS_ENABLED(CONFIG_CPU_BIG_ENDIAN)) \
-		return __raw_writel(val, priv->base + offset + off);	\
+		__raw_writel(val, priv->base + offset + off);		\
 	else								\
 		writel_relaxed(val, priv->base + offset + off);		\
 }
-- 
2.11.0
