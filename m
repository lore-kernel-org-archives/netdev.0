From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH] net: dsa: bcm_sf2: Utilize mask clear/set helpers in bcm_sf2_intr_disable
Date: Thu, 25 Aug 2016 15:20:45 -0700
Message-ID: <1472163645-7058-1-git-send-email-fainelli@broadcom.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <florian.fainelli@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36560 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752158AbcHYWU6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 18:20:58 -0400
Received: by mail-pf0-f194.google.com with SMTP id y134so3846901pfg.3
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 15:20:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian.fainelli@broadcom.com>

And while at it, remove the unecessary writing of zeroes to the CPU_MASK_CLEAR
register since it has no functional use.

refs #SWLINUX-4144

Signed-off-by: Florian Fainelli <florian.fainelli@broadcom.com>
---
 drivers/net/dsa/bcm_sf2.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 30c662adf2cc..706a19a672f3 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -670,12 +670,10 @@ static int bcm_sf2_sw_rst(struct bcm_sf2_priv *priv)
 
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
 
 static int bcm_sf2_sw_setup(struct dsa_switch *ds)
-- 
2.7.4
