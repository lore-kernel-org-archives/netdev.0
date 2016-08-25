From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: bcm_sf2: Utilize mask clear/set helpers in bcm_sf2_intr_disable
Date: Thu, 25 Aug 2016 15:23:41 -0700
Message-ID: <1472163821-7142-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35999 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758054AbcHYWXv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 18:23:51 -0400
Received: by mail-pa0-f67.google.com with SMTP id ez1so3709045pab.3
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 15:23:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And while at it, remove the unecessary writing of zeroes to the CPU_MASK_CLEAR
register since it has no functional use.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 220e5d1948ca..2abeea193843 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1027,12 +1027,10 @@ static int bcm_sf2_sw_rst(struct bcm_sf2_priv *priv)
 
 static void bcm_sf2_intr_disable(struct bcm_sf2_priv *priv)
 {
-	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
+	intrl2_0_mask_set(priv, 0xffffffff);
 	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
-	intrl2_0_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
-	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
+	intrl2_1_mask_set(priv, 0xffffffff);
 	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
-	intrl2_1_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
 }
 
 static void bcm_sf2_identify_ports(struct bcm_sf2_priv *priv,
-- 
2.7.4
