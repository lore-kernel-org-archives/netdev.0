From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] net: remove unnecessary type casting
Date: Sat, 24 Jan 2004 22:17:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124221701.3c1406d3.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.current.

Thanks,
--
~Randy


From: Carlo Perassi <carlo@linux.it>


Hi.
Line 346 of TODO states:
"Lots of unnecessary casts in drivers can be removed"

This micro patch removes some of them.

-- 
Carlo Perassi - http://www.linux.it/~carlo/

diff -puN drivers/net/dl2k.c~netdev_rm_casts drivers/net/dl2k.c

diff -puN drivers/net/dl2k.c~netdev_rm_casts drivers/net/dl2k.c


 linux-262-rc1-bk1-rddunlap/drivers/net/dl2k.c     |    4 ++--
 linux-262-rc1-bk1-rddunlap/drivers/net/fealnx.c   |    2 +-
 linux-262-rc1-bk1-rddunlap/drivers/net/sundance.c |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff -puN drivers/net/dl2k.c~netdev_rm_casts drivers/net/dl2k.c
--- linux-262-rc1-bk1/drivers/net/dl2k.c~netdev_rm_casts	2004-01-23 15:47:13.000000000 -0800
+++ linux-262-rc1-bk1-rddunlap/drivers/net/dl2k.c	2004-01-23 15:47:13.000000000 -0800
@@ -745,7 +745,7 @@ rio_interrupt (int irq, void *dev_instan
 static void 
 rio_free_tx (struct net_device *dev, int irq) 
 {
-	struct netdev_private *np = (struct netdev_private *) dev->priv;
+	struct netdev_private *np = dev->priv;
 	int entry = np->old_tx % TX_RING_SIZE;
 	int tx_use = 0;
 	unsigned long flag = 0;
@@ -855,7 +855,7 @@ tx_error (struct net_device *dev, int tx
 static int
 receive_packet (struct net_device *dev)
 {
-	struct netdev_private *np = (struct netdev_private *) dev->priv;
+	struct netdev_private *np = dev->priv;
 	int entry = np->cur_rx % RX_RING_SIZE;
 	int cnt = 30;
 
diff -puN drivers/net/fealnx.c~netdev_rm_casts drivers/net/fealnx.c
--- linux-262-rc1-bk1/drivers/net/fealnx.c~netdev_rm_casts	2004-01-23 15:47:13.000000000 -0800
+++ linux-262-rc1-bk1-rddunlap/drivers/net/fealnx.c	2004-01-23 15:47:13.000000000 -0800
@@ -1426,7 +1426,7 @@ static irqreturn_t intr_handler(int irq,
 	writel(0, dev->base_addr + IMR);
 
 	ioaddr = dev->base_addr;
-	np = (struct netdev_private *) dev->priv;
+	np = dev->priv;
 
 	do {
 		u32 intr_status = readl(ioaddr + ISR);
diff -puN drivers/net/sundance.c~netdev_rm_casts drivers/net/sundance.c
--- linux-262-rc1-bk1/drivers/net/sundance.c~netdev_rm_casts	2004-01-23 15:47:13.000000000 -0800
+++ linux-262-rc1-bk1-rddunlap/drivers/net/sundance.c	2004-01-23 15:47:13.000000000 -0800
@@ -1136,7 +1136,7 @@ start_tx (struct sk_buff *skb, struct ne
 static int
 reset_tx (struct net_device *dev)
 {
-	struct netdev_private *np = (struct netdev_private*) dev->priv;
+	struct netdev_private *np = dev->priv;
 	long ioaddr = dev->base_addr;
 	struct sk_buff *skb;
 	int i;

_
