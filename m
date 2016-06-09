From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH] net: dsa: mv88e6xxx: make unexported functions static
Date: Thu,  9 Jun 2016 11:30:06 +0100
Message-ID: <1465468206-2890-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@lists.codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-70-136-246.dsl.in-addr.zen.co.uk ([82.70.136.246]:57692 "EHLO
	rainbowdash.ducie.codethink.co.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751808AbcFIKaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 06:30:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver has a number of functions that are not exported or
declared elsewhere, so make them static to avoid the following
warnings from sparse:

drivers/net/dsa/mv88e6xxx.c:113:5: warning: symbol 'mv88e6xxx_reg_read' was not declared. Should it be static?
drivers/net/dsa/mv88e6xxx.c:167:5: warning: symbol 'mv88e6xxx_reg_write' was not declared. Should it be static?
drivers/net/dsa/mv88e6xxx.c:231:5: warning: symbol 'mv88e6xxx_set_addr' was not declared. Should it be static?
drivers/net/dsa/mv88e6xxx.c:367:6: warning: symbol 'mv88e6xxx_ppu_state_init' was not declared. Should it be static?
drivers/net/dsa/mv88e6xxx.c:3157:5: warning: symbol 'mv88e6xxx_phy_page_read' was not declared. Should it be static?
drivers/net/dsa/mv88e6xxx.c:3169:5: warning: symbol 'mv88e6xxx_phy_page_write' was not declared. Should it be static?
drivers/net/dsa/mv88e6xxx.c:3583:26: warning: symbol 'mv88e6xxx_switch_driver' was not declared. Should it be static?
drivers/net/dsa/mv88e6xxx.c:3621:5: warning: symbol 'mv88e6xxx_probe' was not declared. Should it be static?

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
---
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/dsa/mv88e6xxx.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index ba9dfc9..2cebde8 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -110,7 +110,7 @@ static int _mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps,
 	return ret;
 }
 
-int mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps, int addr, int reg)
+static int mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps, int addr, int reg)
 {
 	int ret;
 
@@ -164,8 +164,8 @@ static int _mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
 	return __mv88e6xxx_reg_write(ps->bus, ps->sw_addr, addr, reg, val);
 }
 
-int mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
-			int reg, u16 val)
+static int mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
+			       int reg, u16 val)
 {
 	int ret;
 
@@ -228,7 +228,7 @@ static int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 	return 0;
 }
 
-int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr)
+static int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
@@ -364,7 +364,7 @@ static void mv88e6xxx_ppu_access_put(struct mv88e6xxx_priv_state *ps)
 	mutex_unlock(&ps->ppu_mutex);
 }
 
-void mv88e6xxx_ppu_state_init(struct mv88e6xxx_priv_state *ps)
+static void mv88e6xxx_ppu_state_init(struct mv88e6xxx_priv_state *ps)
 {
 	mutex_init(&ps->ppu_mutex);
 	INIT_WORK(&ps->ppu_work, mv88e6xxx_ppu_reenable_work);
@@ -3154,7 +3154,8 @@ unlock:
 	return err;
 }
 
-int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
+static int mv88e6xxx_phy_page_read(struct dsa_switch *ds,
+				   int port, int page, int reg)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
@@ -3166,8 +3167,8 @@ int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
 	return ret;
 }
 
-int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
-			     int reg, int val)
+static int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
+				    int reg, int val)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
@@ -3580,7 +3581,7 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 	return name;
 }
 
-struct dsa_switch_driver mv88e6xxx_switch_driver = {
+static struct dsa_switch_driver mv88e6xxx_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.probe			= mv88e6xxx_drv_probe,
 	.setup			= mv88e6xxx_setup,
@@ -3618,7 +3619,7 @@ struct dsa_switch_driver mv88e6xxx_switch_driver = {
 	.port_fdb_dump          = mv88e6xxx_port_fdb_dump,
 };
 
-int mv88e6xxx_probe(struct mdio_device *mdiodev)
+static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 {
 	struct device *dev = &mdiodev->dev;
 	struct device_node *np = dev->of_node;
-- 
2.8.1
