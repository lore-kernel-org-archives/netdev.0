From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/4] net: dsa: bcm_sf2: Declare our own dsa_switch_ops
Date: Sun,  8 Jan 2017 14:52:06 -0800
Message-ID: <20170108225208.15431-3-f.fainelli@gmail.com>
References: <20170108225208.15431-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36173 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033717AbdAHW6B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 17:58:01 -0500
Received: by mail-pg0-f65.google.com with SMTP id 75so11596281pgf.3
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 14:58:01 -0800 (PST)
In-Reply-To: <20170108225208.15431-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Utilize the b53 exported functions to fill our bcm_sf2_ops structure,
also making it clear what we utilize and what we specifically override.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 53 +++++++++++++++++++++++++++++------------------
 1 file changed, 33 insertions(+), 20 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 9ec33b51a0ed..fcfc2cb5f3cd 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -977,6 +977,38 @@ static struct b53_io_ops bcm_sf2_io_ops = {
 	.write64 = bcm_sf2_core_write64,
 };
 
+static struct dsa_switch_ops bcm_sf2_ops = {
+	.get_tag_protocol	= bcm_sf2_sw_get_tag_protocol,
+	.setup			= bcm_sf2_sw_setup,
+	.get_strings		= b53_get_strings,
+	.get_ethtool_stats	= b53_get_ethtool_stats,
+	.get_sset_count		= b53_get_sset_count,
+	.get_phy_flags		= bcm_sf2_sw_get_phy_flags,
+	.adjust_link		= bcm_sf2_sw_adjust_link,
+	.fixed_link_update	= bcm_sf2_sw_fixed_link_update,
+	.suspend		= bcm_sf2_sw_suspend,
+	.resume			= bcm_sf2_sw_resume,
+	.get_wol		= bcm_sf2_sw_get_wol,
+	.set_wol		= bcm_sf2_sw_set_wol,
+	.port_enable		= bcm_sf2_port_setup,
+	.port_disable		= bcm_sf2_port_disable,
+	.get_eee		= bcm_sf2_sw_get_eee,
+	.set_eee		= bcm_sf2_sw_set_eee,
+	.port_bridge_join	= b53_br_join,
+	.port_bridge_leave	= b53_br_leave,
+	.port_stp_state_set	= b53_br_set_stp_state,
+	.port_fast_age		= b53_br_fast_age,
+	.port_vlan_filtering	= b53_vlan_filtering,
+	.port_vlan_prepare	= b53_vlan_prepare,
+	.port_vlan_add		= b53_vlan_add,
+	.port_vlan_del		= b53_vlan_del,
+	.port_vlan_dump		= b53_vlan_dump,
+	.port_fdb_prepare	= b53_fdb_prepare,
+	.port_fdb_dump		= b53_fdb_dump,
+	.port_fdb_add		= b53_fdb_add,
+	.port_fdb_del		= b53_fdb_del,
+};
+
 static int bcm_sf2_sw_probe(struct platform_device *pdev)
 {
 	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
@@ -1012,26 +1044,7 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 
 	priv->dev = dev;
 	ds = dev->ds;
-
-	/* Override the parts that are non-standard wrt. normal b53 devices */
-	ds->ops->get_tag_protocol = bcm_sf2_sw_get_tag_protocol;
-	ds->ops->setup = bcm_sf2_sw_setup;
-	ds->ops->get_phy_flags = bcm_sf2_sw_get_phy_flags;
-	ds->ops->adjust_link = bcm_sf2_sw_adjust_link;
-	ds->ops->fixed_link_update = bcm_sf2_sw_fixed_link_update;
-	ds->ops->suspend = bcm_sf2_sw_suspend;
-	ds->ops->resume = bcm_sf2_sw_resume;
-	ds->ops->get_wol = bcm_sf2_sw_get_wol;
-	ds->ops->set_wol = bcm_sf2_sw_set_wol;
-	ds->ops->port_enable = bcm_sf2_port_setup;
-	ds->ops->port_disable = bcm_sf2_port_disable;
-	ds->ops->get_eee = bcm_sf2_sw_get_eee;
-	ds->ops->set_eee = bcm_sf2_sw_set_eee;
-
-	/* Avoid having DSA free our slave MDIO bus (checking for
-	 * ds->slave_mii_bus and ds->ops->phy_read being non-NULL)
-	 */
-	ds->ops->phy_read = NULL;
+	ds->ops = &bcm_sf2_ops;
 
 	dev_set_drvdata(&pdev->dev, priv);
 
-- 
2.9.3
