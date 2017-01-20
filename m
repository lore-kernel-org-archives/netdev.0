From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/7] net: dsa: bcm_sf2: Make SF2_IO64_MACRO() utilize 32-bit macro
Date: Fri, 20 Jan 2017 12:36:28 -0800
Message-ID: <20170120203634.2773-2-f.fainelli@gmail.com>
References: <20170120203634.2773-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34353 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753656AbdATUgo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 15:36:44 -0500
Received: by mail-pf0-f194.google.com with SMTP id y143so6039322pfb.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 12:36:44 -0800 (PST)
In-Reply-To: <20170120203634.2773-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no point inlining the 32-bit direct register read/write part,
just infer it from the existing macro. This will make it easier to
centralize the address rewriting that we are going to introduce later
on.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 44692673e1d5..4531c2333e86 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -125,7 +125,7 @@ static inline u64 name##_readq(struct bcm_sf2_priv *priv, u32 off)	\
 {									\
 	u32 indir, dir;							\
 	spin_lock(&priv->indir_lock);					\
-	dir = __raw_readl(priv->name + off);				\
+	dir = name##_readl(priv, off);					\
 	indir = reg_readl(priv, REG_DIR_DATA_READ);			\
 	spin_unlock(&priv->indir_lock);					\
 	return (u64)indir << 32 | dir;					\
@@ -135,7 +135,7 @@ static inline void name##_writeq(struct bcm_sf2_priv *priv, u64 val,	\
 {									\
 	spin_lock(&priv->indir_lock);					\
 	reg_writel(priv, upper_32_bits(val), REG_DIR_DATA_WRITE);	\
-	__raw_writel(lower_32_bits(val), priv->name + off);		\
+	name##_writel(priv, lower_32_bits(val), off);			\
 	spin_unlock(&priv->indir_lock);					\
 }
 
-- 
2.9.3
