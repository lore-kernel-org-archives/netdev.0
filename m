From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/6] net: dsa: bcm_sf2: disable RGMII interface(s) when link is down
Date: Wed, 24 Sep 2014 17:05:19 -0700
Message-ID: <1411603522-8384-4-git-send-email-f.fainelli@gmail.com>
References: <1411603522-8384-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36744 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaIYAGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 20:06:03 -0400
Received: by mail-pa0-f44.google.com with SMTP id eu11so8835199pac.3
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 17:06:02 -0700 (PDT)
In-Reply-To: <1411603522-8384-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the link is down, disable the RGMII interface to conserve as much
power as possible. We re-enable the RGMII interface whenever the link is
detected.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index d9b7da545063..58b8fef25b96 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -506,6 +506,15 @@ static void bcm_sf2_sw_adjust_link(struct dsa_switch *ds, int port,
 		port_mode = EXT_REVMII;
 		break;
 	default:
+		/* All other PHYs: internal and MoCA */
+		goto force_link;
+	}
+
+	/* If the link is down, just disable the interface to conserve power */
+	if (!phydev->link) {
+		reg = reg_readl(priv, REG_RGMII_CNTRL_P(port));
+		reg &= ~RGMII_MODE_EN;
+		reg_writel(priv, reg, REG_RGMII_CNTRL_P(port));
 		goto force_link;
 	}
 
-- 
1.9.1
