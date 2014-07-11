From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: bcmgenet: fix RGMII_MODE_EN bit
Date: Fri, 11 Jul 2014 16:55:15 -0700
Message-ID: <1405122915-7756-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:52674 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509AbaGKXzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 19:55:20 -0400
Received: by mail-ie0-f174.google.com with SMTP id rd18so1523879iec.19
        for <netdev@vger.kernel.org>; Fri, 11 Jul 2014 16:55:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RGMII_MODE_EN bit was defined to 0, while it is actually 6. It was not
much of a problem on older designs where this was a no-op, and the RGMII
data-path would always be enabled, but newer GENET controllers need to
explicitely enable their RGMII data-pad using this bit.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 0f117105fed1..e23c993b1362 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -331,9 +331,9 @@ struct bcmgenet_mib_counters {
 #define  EXT_ENERGY_DET_MASK		(1 << 12)
 
 #define EXT_RGMII_OOB_CTRL		0x0C
-#define  RGMII_MODE_EN			(1 << 0)
 #define  RGMII_LINK			(1 << 4)
 #define  OOB_DISABLE			(1 << 5)
+#define  RGMII_MODE_EN			(1 << 6)
 #define  ID_MODE_DIS			(1 << 16)
 
 #define EXT_GPHY_CTRL			0x1C
-- 
1.9.1
