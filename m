From: Jeff Garzik <jeff@garzik.org>
Subject: [git patch] net driver fix
Date: Sat, 29 Sep 2007 02:09:33 -0400
Message-ID: <20070929060933.GA18950@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:53453 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753150AbXI2GJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 02:09:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/mv643xx_eth.c |    2 +-
 drivers/net/mv643xx_eth.h |    4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

Dale Farnsworth (1):
      mv643xx_eth: Check ETH_INT_CAUSE_STATE bit

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 456d1e1..34288fe 100644
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
