From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/5] net: dsa: bcm_sf2: Remove probing through old DSA binding
Date: Thu, 18 Aug 2016 15:30:16 -0700
Message-ID: <1471559416-13249-6-git-send-email-f.fainelli@gmail.com>
References: <1471559416-13249-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33191 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753627AbcHSCtx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 22:49:53 -0400
Received: by mail-pf0-f195.google.com with SMTP id i6so682504pfe.0
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:49:53 -0700 (PDT)
In-Reply-To: <1471559416-13249-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove our dsa_switch_driver::drv_probe callback to prevent probing
through the old DSA binding, not that this could happen anymore now that
we have moved the matching compatible string from net/dsa/dsa.c to
drivers/net/dsa/bcm_sf2.c, so this is essentially dead code.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 9f8e007b01d6..8e6fe13dbec3 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -136,20 +136,6 @@ static int bcm_sf2_sw_get_sset_count(struct dsa_switch *ds)
 	return BCM_SF2_STATS_SIZE;
 }
 
-static const char *bcm_sf2_sw_drv_probe(struct device *dsa_dev,
-					struct device *host_dev, int sw_addr,
-					void **_priv)
-{
-	struct bcm_sf2_priv *priv;
-
-	priv = devm_kzalloc(dsa_dev, sizeof(*priv), GFP_KERNEL);
-	if (!priv)
-		return NULL;
-	*_priv = priv;
-
-	return "Broadcom Starfighter 2";
-}
-
 static void bcm_sf2_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
@@ -1592,7 +1578,6 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 
 static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_BRCM,
-	.probe			= bcm_sf2_sw_drv_probe,
 	.setup			= bcm_sf2_sw_setup,
 	.set_addr		= bcm_sf2_sw_set_addr,
 	.get_phy_flags		= bcm_sf2_sw_get_phy_flags,
-- 
2.7.4
