From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] tr/3c359: handle kmalloc failures during init
Date: Sun, 18 Jan 2004 21:15:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040118211558.7d85c1e2.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.current.


From: Pablo Menichini <pablo@menichini.com.ar>
and maximilian attems <janitor@sternwelten.at>


while looking at kj mails from 200212 and 200301
this patch slept through
originally from: Pablo Menichini <pablo@menichini.com.ar>
rediffed and compile tested
patch applies on plain 2.6.0

maximilian attems <janitor@sternwelten.at>

handle kmalloc failures during init

diff -puN drivers/net/tokenring/3c359.c~tr3c_kmalloc drivers/net/tokenring/3c359.c


 linux-261-bk4-kj1-rddunlap/drivers/net/tokenring/3c359.c |   13 +++++++++++++
 1 files changed, 13 insertions(+)

diff -puN drivers/net/tokenring/3c359.c~tr3c_kmalloc drivers/net/tokenring/3c359.c
--- linux-261-bk4-kj1/drivers/net/tokenring/3c359.c~tr3c_kmalloc	2004-01-16 16:03:29.000000000 -0800
+++ linux-261-bk4-kj1-rddunlap/drivers/net/tokenring/3c359.c	2004-01-16 16:03:29.000000000 -0800
@@ -642,7 +642,20 @@ static int xl_open(struct net_device *de
 	 */
 	/* These MUST be on 8 byte boundaries */
 	xl_priv->xl_tx_ring = kmalloc((sizeof(struct xl_tx_desc) * XL_TX_RING_SIZE) + 7, GFP_DMA | GFP_KERNEL) ; 
+	if (xl_priv->xl_tx_ring == NULL) {
+		printk(KERN_WARNING "%s: Not enough memory to allocate rx buffers.\n",
+				     dev->name);
+		free_irq(dev->irq,dev);
+		return -ENOMEM;
+	}
 	xl_priv->xl_rx_ring = kmalloc((sizeof(struct xl_rx_desc) * XL_RX_RING_SIZE) +7, GFP_DMA | GFP_KERNEL) ; 
+	if (xl_priv->xl_tx_ring == NULL) {
+		printk(KERN_WARNING "%s: Not enough memory to allocate rx buffers.\n",
+				     dev->name);
+		free_irq(dev->irq,dev);
+		kfree(xl_priv->xl_tx_ring);
+		return -ENOMEM;
+	}
 	memset(xl_priv->xl_tx_ring,0,sizeof(struct xl_tx_desc) * XL_TX_RING_SIZE) ; 
 	memset(xl_priv->xl_rx_ring,0,sizeof(struct xl_rx_desc) * XL_RX_RING_SIZE) ; 
 

_


--
~Randy
