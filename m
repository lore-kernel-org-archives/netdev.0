From: Guenter Roeck <linux@roeck-us.net>
Subject: [RFT PATCH 18/18] net: dsa: mv88e6131: Add HW bridging support
Date: Sat, 21 Mar 2015 08:46:55 -0700
Message-ID: <1426952815-4642-19-git-send-email-linux@roeck-us.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:40453 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbbCUPsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 11:48:12 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YZLdD-0001uf-S1
	for netdev@vger.kernel.org; Sat, 21 Mar 2015 15:48:12 +0000
In-Reply-To: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HW bridging support for mv88e6131 and compatible chips is similar
to other chips of the series, so we can add support to it
by just setting the respective function vectors.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6131.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 98a3668..60b8122 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -377,6 +377,12 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.get_strings		= mv88e6131_get_strings,
 	.get_ethtool_stats	= mv88e6131_get_ethtool_stats,
 	.get_sset_count		= mv88e6131_get_sset_count,
+	.port_join_bridge	= mv88e6xxx_join_bridge,
+	.port_leave_bridge	= mv88e6xxx_leave_bridge,
+	.port_stp_update	= mv88e6xxx_port_stp_update,
+	.fdb_add		= mv88e6xxx_port_fdb_add,
+	.fdb_del		= mv88e6xxx_port_fdb_del,
+	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
 };
 
 MODULE_ALIAS("platform:mv88e6085");
-- 
2.1.0
