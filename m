From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/4] net: dsa: bcm_sf2: Use correct I/O accessors
Date: Tue, 29 Aug 2017 13:35:16 -0700
Message-ID: <1504038918-49254-3-git-send-email-f.fainelli@gmail.com>
References: <1504038918-49254-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:38868 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751558AbdH2UlS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 16:41:18 -0400
Received: by mail-qt0-f195.google.com with SMTP id d15so3751713qta.5
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 13:41:18 -0700 (PDT)
In-Reply-To: <1504038918-49254-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Starfigther 2 driver currently uses __raw_{read,write}l which means
native I/O endian. This works correctly for an ARM LE kernel (default)
but fails miserably on an ARM BE (BE8) kernel where registers are kept
little endian, so replace uses with {read,write}l_relaxed here which is
what we want because this is all performance sensitive code.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 7d3030e04f11..d9c96b281fc0 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -130,12 +130,12 @@ static inline u32 bcm_sf2_mangle_addr(struct bcm_sf2_priv *priv, u32 off)
 #define SF2_IO_MACRO(name) \
 static inline u32 name##_readl(struct bcm_sf2_priv *priv, u32 off)	\
 {									\
-	return __raw_readl(priv->name + off);				\
+	return readl_relaxed(priv->name + off);				\
 }									\
 static inline void name##_writel(struct bcm_sf2_priv *priv,		\
 				  u32 val, u32 off)			\
 {									\
-	__raw_writel(val, priv->name + off);				\
+	writel_relaxed(val, priv->name + off);				\
 }									\
 
 /* Accesses to 64-bits register requires us to latch the hi/lo pairs
@@ -179,23 +179,23 @@ static inline u32 bcm_sf2_mangle_addr(struct bcm_sf2_priv *priv, u32 off)
 static inline u32 core_readl(struct bcm_sf2_priv *priv, u32 off)
 {
 	u32 tmp = bcm_sf2_mangle_addr(priv, off);
-	return __raw_readl(priv->core + tmp);
+	return readl_relaxed(priv->core + tmp);
 }
 
 static inline void core_writel(struct bcm_sf2_priv *priv, u32 val, u32 off)
 {
 	u32 tmp = bcm_sf2_mangle_addr(priv, off);
-	__raw_writel(val, priv->core + tmp);
+	writel_relaxed(val, priv->core + tmp);
 }
 
 static inline u32 reg_readl(struct bcm_sf2_priv *priv, u16 off)
 {
-	return __raw_readl(priv->reg + priv->reg_offsets[off]);
+	return readl_relaxed(priv->reg + priv->reg_offsets[off]);
 }
 
 static inline void reg_writel(struct bcm_sf2_priv *priv, u32 val, u16 off)
 {
-	__raw_writel(val, priv->reg + priv->reg_offsets[off]);
+	writel_relaxed(val, priv->reg + priv->reg_offsets[off]);
 }
 
 SF2_IO64_MACRO(core);
-- 
1.9.1
