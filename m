From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH] mv643xx_eth: Check ETH_INT_CAUSE_STATE bit
Date: Fri, 28 Sep 2007 06:30:43 -0700
Message-ID: <20070928133043.GA779@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Martyn Welch <martyn.welch@radstone.co.uk>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:50720 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755123AbXI1Nao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 09:30:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 468d09f8946d40228c56de26fe4874b2f98067ed masked the "state"
interrupt (bit 20 of the cause register). This results in Radstone's
PPC7D repeatedly re-entering the interrupt routine, locking up the
board. The following patch returns the required handling for this
interrupt. 

Signed-off-by: Martyn Welch <martyn.welch@radstone.co.uk>
Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

---
Jeff, this is a bug fix.

 drivers/net/mv643xx_eth.c |    2 +-
 drivers/net/mv643xx_eth.h |    4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1799eee..1785d15 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -534,7 +534,7 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 	}
 
 	/* PHY status changed */
-	if (eth_int_cause_ext & ETH_INT_CAUSE_PHY) {
+	if (eth_int_cause_ext & (ETH_INT_CAUSE_PHY | ETH_INT_CAUSE_STATE)) {
 		struct ethtool_cmd cmd;
 
 		if (mii_link_ok(&mp->mii)) {
diff --git a/drivers/net/mv643xx_eth.h b/drivers/net/mv643xx_eth.h
index 82f8c0c..565b966 100644
--- a/drivers/net/mv643xx_eth.h
+++ b/drivers/net/mv643xx_eth.h
@@ -64,7 +64,9 @@
 #define ETH_INT_CAUSE_TX_ERROR	(ETH_TX_QUEUES_ENABLED << 8)
 #define ETH_INT_CAUSE_TX	(ETH_INT_CAUSE_TX_DONE | ETH_INT_CAUSE_TX_ERROR)
 #define ETH_INT_CAUSE_PHY	0x00010000
-#define ETH_INT_UNMASK_ALL_EXT	(ETH_INT_CAUSE_TX | ETH_INT_CAUSE_PHY)
+#define ETH_INT_CAUSE_STATE	0x00100000
+#define ETH_INT_UNMASK_ALL_EXT	(ETH_INT_CAUSE_TX | ETH_INT_CAUSE_PHY | \
+					ETH_INT_CAUSE_STATE)
 
 #define ETH_INT_MASK_ALL	0x00000000
 #define ETH_INT_MASK_ALL_EXT	0x00000000

