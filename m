From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(19/20): Ensure NAPI poll routine only clears IRQs it handles
Date: Mon, 28 Mar 2005 17:00:24 -0700
Message-ID: <20050329000023.GS29098@xyzzy>
References: <20050328233807.GA28423@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        James Chapman <jchapman@katalix.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328233807.GA28423@xyzzy>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -1635,9 +1635,9 @@
 
 	if (done) {
 		spin_lock_irqsave(&mp->lock, flags);
+		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num),
+				  ~0x0007fffd);
 		__netif_rx_complete(dev);
-		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
-		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
 		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
 				  INT_CAUSE_UNMASK_ALL);
 		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port_num),
