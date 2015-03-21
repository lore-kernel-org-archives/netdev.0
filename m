From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 15/18] net: dsa: mv88e6171: Add EEE support to the mv88e6172
Date: Sat, 21 Mar 2015 08:46:52 -0700
Message-ID: <1426952815-4642-16-git-send-email-linux@roeck-us.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:40400 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbbCUPsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 11:48:05 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YZLd6-0001nf-N7
	for netdev@vger.kernel.org; Sat, 21 Mar 2015 15:48:04 +0000
In-Reply-To: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>

The mv88e6172 has support for EEE. Check for the product ID and call
the common code if applicable.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6171.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 54ebfed..e1700cd 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -390,6 +390,28 @@ static int mv88e6171_get_sset_count(struct dsa_switch *ds)
 	return ARRAY_SIZE(mv88e6171_hw_stats);
 }
 
+static int mv88e6171_get_eee(struct dsa_switch *ds, int port,
+			     struct ethtool_eee *e)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	if (ps->id == ID_6172)
+		return mv88e6xxx_get_eee(ds, port, e);
+
+	return -EOPNOTSUPP;
+}
+
+static int mv88e6171_set_eee(struct dsa_switch *ds, int port,
+			     struct phy_device *phydev, struct ethtool_eee *e)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	if (ps->id == ID_6172)
+		return mv88e6xxx_set_eee(ds, port, phydev, e);
+
+	return -EOPNOTSUPP;
+}
+
 struct dsa_switch_driver mv88e6171_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
@@ -402,6 +424,8 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.get_strings		= mv88e6171_get_strings,
 	.get_ethtool_stats	= mv88e6171_get_ethtool_stats,
 	.get_sset_count		= mv88e6171_get_sset_count,
+	.set_eee		= mv88e6171_set_eee,
+	.get_eee		= mv88e6171_get_eee,
 #ifdef CONFIG_NET_DSA_HWMON
 	.get_temp               = mv88e6xxx_get_temp,
 #endif
-- 
2.1.0
