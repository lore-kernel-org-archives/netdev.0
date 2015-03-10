From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 3/3] net: dsa: mv88e6171: Add EEE support to the mv88e6172
Date: Tue, 10 Mar 2015 23:05:59 +0100
Message-ID: <1426025160-13992-4-git-send-email-andrew@lunn.ch>
References: <1426025160-13992-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57224 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752311AbbCJWJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 18:09:35 -0400
In-Reply-To: <1426025160-13992-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6172 has support for EEE. Check for the product ID and call
the common code if applicable.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6171.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 4fa0614e8ff3..f3b5a0839e12 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -398,6 +398,28 @@ static int mv88e6171_get_sset_count(struct dsa_switch *ds)
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
@@ -410,6 +432,8 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.get_strings		= mv88e6171_get_strings,
 	.get_ethtool_stats	= mv88e6171_get_ethtool_stats,
 	.get_sset_count		= mv88e6171_get_sset_count,
+	.set_eee		= mv88e6171_set_eee,
+	.get_eee		= mv88e6171_get_eee,
 #ifdef CONFIG_NET_DSA_HWMON
 	.get_temp               = mv88e6xxx_get_temp,
 #endif
-- 
2.1.4
