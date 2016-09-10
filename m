From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: bcm_sf2: Get VLAN_PORT_MASK from b53_device
Date: Sat, 10 Sep 2016 12:39:03 -0700
Message-ID: <1473536343-13427-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33837 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751618AbcIJTjH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 15:39:07 -0400
Received: by mail-oi0-f66.google.com with SMTP id u64so30140oia.1
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2016 12:39:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While migrating the bcm_sf2 driver to use b53_common, we left a small
piece untouched where we kept our local copy of the per-port
port_vlan_ctl bitmask value. This value is now maintained by b53_device
so we need to use it instead of our local (and now stale) copy of it.

Fixes: f458995b9ad8 ("net: dsa: bcm_sf2: Utilize core B53 driver when possible")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 2 +-
 drivers/net/dsa/bcm_sf2.h | 2 --
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 51f1fc0dddc5..5bf4f3452676 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -256,7 +256,7 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 	reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(port));
 	reg &= ~PORT_VLAN_CTRL_MASK;
 	reg |= (1 << port);
-	reg |= priv->port_sts[port].vlan_ctl_mask;
+	reg |= priv->dev->ports[port].vlan_ctl_mask;
 	core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(port));
 
 	bcm_sf2_imp_vlan_setup(ds, cpu_port);
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 46c4ea796574..44692673e1d5 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -50,8 +50,6 @@ struct bcm_sf2_port_status {
 	unsigned int link;
 
 	struct ethtool_eee eee;
-
-	u16 vlan_ctl_mask;
 };
 
 struct bcm_sf2_priv {
-- 
2.7.4
