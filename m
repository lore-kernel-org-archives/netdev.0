From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/5] net: dsa: bcm_sf2: Ensure we re-negotiate EEE during after link change
Date: Tue, 22 Nov 2016 11:40:58 -0800
Message-ID: <20161122194058.29820-6-f.fainelli@gmail.com>
References: <20161122194058.29820-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, bcm-kernel-feedback-list@broadcom.com,
        andrew@lunn.ch, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35055 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933871AbcKVTlO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 14:41:14 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so2899125pga.2
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 11:41:14 -0800 (PST)
In-Reply-To: <20161122194058.29820-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case the link change and EEE is enabled or disabled, always try to
re-negotiate this with the link partner.

Fixes: 450b05c15f9c ("net: dsa: bcm_sf2: add support for controlling EEE")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index e3ee27ce13dd..9ec33b51a0ed 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -588,6 +588,7 @@ static void bcm_sf2_sw_adjust_link(struct dsa_switch *ds, int port,
 				   struct phy_device *phydev)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
+	struct ethtool_eee *p = &priv->port_sts[port].eee;
 	u32 id_mode_dis = 0, port_mode;
 	const char *str = NULL;
 	u32 reg;
@@ -662,6 +663,9 @@ static void bcm_sf2_sw_adjust_link(struct dsa_switch *ds, int port,
 		reg |= DUPLX_MODE;
 
 	core_writel(priv, reg, CORE_STS_OVERRIDE_GMIIP_PORT(port));
+
+	if (!phydev->is_pseudo_fixed_link)
+		p->eee_enabled = bcm_sf2_eee_init(ds, port, phydev);
 }
 
 static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
-- 
2.9.3
