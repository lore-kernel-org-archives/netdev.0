From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 18/21] net: dsa: mv88e6131: drop frames priorities setup
Date: Mon,  9 May 2016 13:22:55 -0400
Message-ID: <1462814578-6249-19-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462814578-6249-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:50945 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752879AbcEIRXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 13:23:50 -0400
In-Reply-To: <1462814578-6249-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

6131 is the only driver which setups the priority of IGMP/MLD snoop
frames and ARP frames to the highest setting. Drop such change until we
figure out a common configuration for all switch models.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6131.c | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index b6ca07b..da28327 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -58,20 +58,6 @@ static const char *mv88e6131_drv_probe(struct device *dsa_dev,
 				   ARRAY_SIZE(mv88e6131_table));
 }
 
-static int mv88e6131_setup_global(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
-	/* Force the priority of IGMP/MLD snoop frames and ARP frames
-	 * to the highest setting.
-	 */
-	return mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_PRIO_OVERRIDE,
-				   GLOBAL2_PRIO_OVERRIDE_FORCE_SNOOP |
-				   7 << GLOBAL2_PRIO_OVERRIDE_SNOOP_SHIFT |
-				   GLOBAL2_PRIO_OVERRIDE_FORCE_ARP |
-				   7 << GLOBAL2_PRIO_OVERRIDE_ARP_SHIFT);
-}
-
 static int mv88e6131_setup(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -83,10 +69,6 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	ret = mv88e6131_setup_global(ds);
-	if (ret < 0)
-		return ret;
-
 	return mv88e6xxx_setup_ports(ds);
 }
 
-- 
2.8.2
