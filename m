From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 8/8] dsa: mv88e6131: Don't special case a single device
Date: Thu, 14 Apr 2016 01:59:58 +0200
Message-ID: <1460591998-20598-9-git-send-email-andrew@lunn.ch>
References: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55183 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754185AbcDNABG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 20:01:06 -0400
In-Reply-To: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When multiple switches are interconnected in a tree, a routing table
is used for directing packets out the correct port towards a remote
destination. This works equally well for a single switch, since the
routing table is empty. So don't special case for a single switch.
This makes the mv88e6131 behave like the other drivers.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6131.c | 16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 969f67c77835..c7ee11f73be6 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -74,18 +74,12 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	if (ret)
 		return ret;
 
-	/* Disable cascade port functionality unless this device
-	 * is used in a cascade configuration, and set the switch's
-	 * DSA device number.
+	/* Set the switch's DSA device number and enable the use of
+	 * the routing table.
 	 */
-	if (ds->dst->pd->nr_chips > 1)
-		ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL_2,
-					  GLOBAL_CONTROL_2_MULTIPLE_CASCADE |
-					  (ds->index & 0x1f));
-	else
-		ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL_2,
-					  GLOBAL_CONTROL_2_NO_CASCADE |
-					  (ds->index & 0x1f));
+	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL_2,
+				  GLOBAL_CONTROL_2_MULTIPLE_CASCADE |
+				  (ds->index & 0x1f));
 	if (ret)
 		return ret;
 
-- 
2.7.0
