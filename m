From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: wan/dscc4: Remove unused timer
Date: Wed, 25 Oct 2017 03:53:42 -0700
Message-ID: <20171025105342.GA146617@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This removes an entirely unused timer, which avoids needing to convert it
to timer_setup().

Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wan/dscc4.c | 20 --------------------
 1 file changed, 20 deletions(-)

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 64f176496da4..c0b0f525c87c 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -223,8 +223,6 @@ struct dscc4_dev_priv {
 
 	u32 scc_regs[SCC_REGISTERS_MAX]; /* Cf errata DS5 p.4 */
 
-	struct timer_list timer;
-
         struct dscc4_pci_priv *pci_priv;
         spinlock_t lock;
 
@@ -369,7 +367,6 @@ static int dscc4_close(struct net_device *);
 static int dscc4_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static int dscc4_init_ring(struct net_device *);
 static void dscc4_release_ring(struct dscc4_dev_priv *);
-static void dscc4_timer(unsigned long);
 static void dscc4_tx_timeout(struct net_device *);
 static irqreturn_t dscc4_irq(int irq, void *dev_id);
 static int dscc4_hdlc_attach(struct net_device *, unsigned short, unsigned short);
@@ -983,19 +980,6 @@ static int dscc4_found1(struct pci_dev *pdev, void __iomem *ioaddr)
 	return ret;
 };
 
-/* FIXME: get rid of the unneeded code */
-static void dscc4_timer(unsigned long data)
-{
-	struct net_device *dev = (struct net_device *)data;
-	struct dscc4_dev_priv *dpriv = dscc4_priv(dev);
-//	struct dscc4_pci_priv *ppriv;
-
-	goto done;
-done:
-        dpriv->timer.expires = jiffies + TX_TIMEOUT;
-        add_timer(&dpriv->timer);
-}
-
 static void dscc4_tx_timeout(struct net_device *dev)
 {
 	/* FIXME: something is missing there */
@@ -1127,9 +1111,6 @@ static int dscc4_open(struct net_device *dev)
 done:
 	netif_start_queue(dev);
 
-	setup_timer(&dpriv->timer, dscc4_timer, (unsigned long)dev);
-        dpriv->timer.expires = jiffies + 10*HZ;
-        add_timer(&dpriv->timer);
 	netif_carrier_on(dev);
 
 	return 0;
@@ -1197,7 +1178,6 @@ static int dscc4_close(struct net_device *dev)
 {
 	struct dscc4_dev_priv *dpriv = dscc4_priv(dev);
 
-	del_timer_sync(&dpriv->timer);
 	netif_stop_queue(dev);
 
 	scc_patchl(PowerUp | Vis, 0, dpriv, dev, CCR0);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
