From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/2] net: dsa: mv88e6xxx: 6161 uses global 2 for PHY access
Date: Fri,  2 Jun 2017 23:22:45 +0200
Message-ID: <1496438566-30612-2-git-send-email-andrew@lunn.ch>
References: <1496438566-30612-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Chris Healy <cphealy@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34985 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751267AbdFBVXM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Jun 2017 17:23:12 -0400
In-Reply-To: <1496438566-30612-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Access to the internal PHYs of the 6161 and 6123 go through global 2
SMI registers. Fix the ops structure.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 7cf470c3e662..80ed4ab84028 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2455,8 +2455,8 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 static const struct mv88e6xxx_ops mv88e6123_ops = {
 	/* MV88E6XXX_FAMILY_6165 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
-	.phy_read = mv88e6165_phy_read,
-	.phy_write = mv88e6165_phy_write,
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
@@ -2544,8 +2544,8 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 static const struct mv88e6xxx_ops mv88e6161_ops = {
 	/* MV88E6XXX_FAMILY_6165 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
-	.phy_read = mv88e6165_phy_read,
-	.phy_write = mv88e6165_phy_write,
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
-- 
2.11.0
