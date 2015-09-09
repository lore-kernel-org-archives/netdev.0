From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: bcm_sf2: Fix 64-bits register writes
Date: Tue,  8 Sep 2015 20:06:41 -0700
Message-ID: <1441768001-25318-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35096 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754623AbbIIDJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 23:09:27 -0400
Received: by pacfv12 with SMTP id fv12so145761622pac.2
        for <netdev@vger.kernel.org>; Tue, 08 Sep 2015 20:09:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macro to write 64-bits quantities to the 32-bits register swapped
the value and offsets arguments, we want to preserve the ordering of the
arguments with respect to how writel() is implemented for instance:
value first, offset/base second.

Fixes: 246d7f773c13 ("net: dsa: add Broadcom SF2 switch driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
David,

Can you also queue this one for -stable? Thanks!

 drivers/net/dsa/bcm_sf2.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 22e2ebf31333..789d7b7737da 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -112,8 +112,8 @@ static inline u64 name##_readq(struct bcm_sf2_priv *priv, u32 off)	\
 	spin_unlock(&priv->indir_lock);					\
 	return (u64)indir << 32 | dir;					\
 }									\
-static inline void name##_writeq(struct bcm_sf2_priv *priv, u32 off,	\
-							u64 val)	\
+static inline void name##_writeq(struct bcm_sf2_priv *priv, u64 val,	\
+							u32 off)	\
 {									\
 	spin_lock(&priv->indir_lock);					\
 	reg_writel(priv, upper_32_bits(val), REG_DIR_DATA_WRITE);	\
-- 
2.1.0
