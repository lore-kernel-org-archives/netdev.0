From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH] mv643xx: Clear pending interrupts before calling request_irq
Date: Wed, 7 Mar 2007 22:21:23 -0700
Message-ID: <20070308052123.GA5077@xyzzy.farnsworth.org>
References: <20070306164638.GB22043@xyzzy.farnsworth.org> <983376.58847.qm@web32410.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	giri@lmc.cs.sunysb.edu, Giridhar Pemmasani <pgiri@yahoo.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:4869 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932114AbXCHFVZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 00:21:25 -0500
Content-Disposition: inline
In-Reply-To: <983376.58847.qm@web32410.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dale Farnsworth <dale@farnsworth.org>

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
Acked-by: Giridhar Pemmasani <pgiri@yahoo.com>

---

Giri, thank you very much for reporting the problem and confirming
the fix.

Jeff, please apply.

Andrew, this patch supersedes the -mm patch:
	mv643xx-ethernet-driver-irq-registration-fix.patch

 drivers/net/mv643xx_eth.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 3e045a6..192b390 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -787,6 +787,12 @@ static int mv643xx_eth_open(struct net_device *dev)
 	unsigned int size;
 	int err;
 
+	/* Clear any pending ethernet port interrupts */
+	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
+	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+	/* wait for previous write to complete */
+	mv_read (MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num));
+
 	err = request_irq(dev->irq, mv643xx_eth_int_handler,
 			IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
 	if (err) {
@@ -875,10 +881,6 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	mv643xx_eth_rx_refill_descs(dev);	/* Fill RX ring with skb's */
 
-	/* Clear any pending ethernet port interrupts */
-	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
-	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
-
 	eth_port_start(dev);
 
 	/* Interrupt Coalescing */


