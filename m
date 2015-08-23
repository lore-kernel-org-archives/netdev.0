From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 5/9] net: dsa: Allow DSA and CPU ports to have a phy-mode property
Date: Sun, 23 Aug 2015 11:46:56 +0200
Message-ID: <1440323220-20438-6-git-send-email-andrew@lunn.ch>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38101 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752319AbbHWJzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2015 05:55:41 -0400
In-Reply-To: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It can be useful for DSA and CPU ports to have a phy-mode property, in
particular to specify RGMII delays. Parse the property and set it in
the fixed-link phydev.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index afff17341b73..76e3800765f8 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -181,7 +181,7 @@ static int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct net_device *master)
 	struct dsa_chip_data *cd = ds->pd;
 	struct device_node *port_dn;
 	struct phy_device *phydev;
-	int ret, port;
+	int ret, port, mode;
 
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
 		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
@@ -196,6 +196,12 @@ static int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct net_device *master)
 				return ret;
 			}
 			phydev = of_phy_find_device(port_dn);
+
+			mode = of_get_phy_mode(port_dn);
+			if (mode < 0)
+				mode = PHY_INTERFACE_MODE_NA;
+			phydev->interface = mode;
+
 			genphy_config_init(phydev);
 			genphy_read_status(phydev);
 			if (ds->drv->adjust_link)
-- 
2.5.0
