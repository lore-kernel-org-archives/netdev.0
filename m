From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 16/18] net: dsa: mv88e6171: Add support for hardware bridging
Date: Sat, 21 Mar 2015 08:46:53 -0700
Message-ID: <1426952815-4642-17-git-send-email-linux@roeck-us.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:40414 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbbCUPsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 11:48:07 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YZLd9-0001qG-0x
	for netdev@vger.kernel.org; Sat, 21 Mar 2015 15:48:07 +0000
In-Reply-To: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>

Wire up the common code for setting up hardware bridging
and access to the forwarding database.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6171.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index e1700cd..18cfead 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -431,6 +431,12 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 #endif
 	.get_regs_len		= mv88e6xxx_get_regs_len,
 	.get_regs		= mv88e6xxx_get_regs,
+	.port_join_bridge       = mv88e6xxx_join_bridge,
+	.port_leave_bridge      = mv88e6xxx_leave_bridge,
+	.port_stp_update        = mv88e6xxx_port_stp_update,
+	.fdb_add		= mv88e6xxx_port_fdb_add,
+	.fdb_del		= mv88e6xxx_port_fdb_del,
+	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
 };
 
 MODULE_ALIAS("platform:mv88e6171");
-- 
2.1.0
