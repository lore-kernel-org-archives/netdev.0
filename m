From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/7] chelsio: move return, break and continue statements on their own line
Date: Tue, 12 Dec 2006 00:20:46 +0100
Message-ID: <20061211232046.GB8568@electric-eye.fr.zoreil.com>
References: <20061211231558.GA8568@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40051 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750722AbWLKXVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 18:21:03 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061211231558.GA8568@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/chelsio/espi.c      |    3 ++-
 drivers/net/chelsio/ixf1010.c   |    9 ++++++---
 drivers/net/chelsio/mv88e1xxx.c |    6 ++++--
 drivers/net/chelsio/subr.c      |    6 ++++--
 drivers/net/chelsio/vsc7326.c   |    3 ++-
 drivers/net/chelsio/vsc8244.c   |    3 ++-
 6 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/chelsio/espi.c b/drivers/net/chelsio/espi.c
index 4192f0f..44d2603 100644
--- a/drivers/net/chelsio/espi.c
+++ b/drivers/net/chelsio/espi.c
@@ -301,7 +301,8 @@ void t1_espi_set_misc_ctrl(adapter_t *ad
 {
 	struct peespi *espi = adapter->espi;
 
-	if (!is_T2(adapter)) return;
+	if (!is_T2(adapter))
+		return;
 	spin_lock(&espi->lock);
 	espi->misc_ctrl = (val & ~MON_MASK) |
 			  (espi->misc_ctrl & MON_MASK);
diff --git a/drivers/net/chelsio/ixf1010.c b/drivers/net/chelsio/ixf1010.c
index 5b8f144..91a5bf7 100644
--- a/drivers/net/chelsio/ixf1010.c
+++ b/drivers/net/chelsio/ixf1010.c
@@ -273,7 +273,8 @@ static int mac_set_rx_mode(struct cmac *
 static int mac_set_mtu(struct cmac *mac, int mtu)
 {
 	/* MAX_FRAME_SIZE inludes header + FCS, mtu doesn't */
-	if (mtu > (MAX_FRAME_SIZE - 14 - 4)) return -EINVAL;
+	if (mtu > (MAX_FRAME_SIZE - 14 - 4))
+		return -EINVAL;
 	t1_tpi_write(mac->adapter, MACREG(mac, REG_MAX_FRAME_SIZE),
 		     mtu + 14 + 4);
 	return 0;
@@ -460,10 +461,12 @@ static struct cmac *ixf1010_mac_create(a
 	struct cmac *mac;
 	u32 val;
 
-	if (index > 9) return NULL;
+	if (index > 9)
+		return NULL;
 
 	mac = kzalloc(sizeof(*mac) + sizeof(cmac_instance), GFP_KERNEL);
-	if (!mac) return NULL;
+	if (!mac)
+		return NULL;
 
 	mac->ops = &ixf1010_ops;
 	mac->instance = (cmac_instance *)(mac + 1);
diff --git a/drivers/net/chelsio/mv88e1xxx.c b/drivers/net/chelsio/mv88e1xxx.c
index 28ac93f..75fac85 100644
--- a/drivers/net/chelsio/mv88e1xxx.c
+++ b/drivers/net/chelsio/mv88e1xxx.c
@@ -308,7 +308,8 @@ static int mv88e1xxx_interrupt_handler(s
 				MV88E1XXX_INTERRUPT_STATUS_REGISTER,
 				&cause);
 		cause &= INTR_ENABLE_MASK;
-		if (!cause) break;
+		if (!cause)
+			break;
 
 		if (cause & MV88E1XXX_INTR_LINK_CHNG) {
 			(void) simple_mdio_read(cphy,
@@ -360,7 +361,8 @@ static struct cphy *mv88e1xxx_phy_create
 {
 	struct cphy *cphy = kzalloc(sizeof(*cphy), GFP_KERNEL);
 
-	if (!cphy) return NULL;
+	if (!cphy)
+		return NULL;
 
 	cphy_init(cphy, adapter, phy_addr, &mv88e1xxx_ops, mdio_ops);
 
diff --git a/drivers/net/chelsio/subr.c b/drivers/net/chelsio/subr.c
index 22ed9a3..38dbaf2 100644
--- a/drivers/net/chelsio/subr.c
+++ b/drivers/net/chelsio/subr.c
@@ -612,7 +612,8 @@ #ifdef CONFIG_CHELSIO_T1_1G
                 int i, port_bit;
 		for_each_port(adapter, i) {
 			port_bit = i + 1;
-			if (!(cause & (1 << port_bit))) continue;
+			if (!(cause & (1 << port_bit)))
+				continue;
 
 	                phy = adapter->port[i].phy;
 			phy_cause = phy->ops->interrupt_handler(phy);
@@ -688,7 +689,8 @@ #ifdef CONFIG_CHELSIO_T1_COUGAR
 
 			for_each_port(adapter, i) {
 				port_bit = i ? i + 1 : 0;
-				if (!(cause & (1 << port_bit))) continue;
+				if (!(cause & (1 << port_bit)))
+					continue;
 
 				phy = adapter->port[i].phy;
 				phy_cause = phy->ops->interrupt_handler(phy);
diff --git a/drivers/net/chelsio/vsc7326.c b/drivers/net/chelsio/vsc7326.c
index 85dc3b1..3355441 100644
--- a/drivers/net/chelsio/vsc7326.c
+++ b/drivers/net/chelsio/vsc7326.c
@@ -686,7 +686,8 @@ static struct cmac *vsc7326_mac_create(a
 	int i;
 
 	mac = kzalloc(sizeof(*mac) + sizeof(cmac_instance), GFP_KERNEL);
-	if (!mac) return NULL;
+	if (!mac)
+		return NULL;
 
 	mac->ops = &vsc7326_ops;
 	mac->instance = (cmac_instance *)(mac + 1);
diff --git a/drivers/net/chelsio/vsc8244.c b/drivers/net/chelsio/vsc8244.c
index c493e78..f947cf6 100644
--- a/drivers/net/chelsio/vsc8244.c
+++ b/drivers/net/chelsio/vsc8244.c
@@ -347,7 +347,8 @@ static struct cphy* vsc8244_phy_create(a
 {
 	struct cphy *cphy = kzalloc(sizeof(*cphy), GFP_KERNEL);
 
-	if (!cphy) return NULL;
+	if (!cphy)
+		return NULL;
 
 	cphy_init(cphy, adapter, phy_addr, &vsc8244_ops, mdio_ops);
 
-- 
1.4.2.3

