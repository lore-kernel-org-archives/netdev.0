From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/lib82596.c: use %pM to shown MAC address
Date: Mon, 28 Dec 2009 17:43:17 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F4C1@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751839AbZL1WnQ@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

The only difference in the output is that the MAC address is
shown in the usual colon-separated hex notation instead of
space-separated.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index b117f7f..b60efd4 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -1094,11 +1094,9 @@ static int __devinit i82596_probe(struct net_device *dev)
 		return i;
 	};
 
-	DEB(DEB_PROBE, printk(KERN_INFO "%s: 82596 at %#3lx,",
-			      dev->name, dev->base_addr));
-	for (i = 0; i < 6; i++)
-		DEB(DEB_PROBE, printk(" %2.2X", dev->dev_addr[i]));
-	DEB(DEB_PROBE, printk(" IRQ %d.\n", dev->irq));
+	DEB(DEB_PROBE, printk(KERN_INFO "%s: 82596 at %#3lx, %pM IRQ %d.\n",
+			      dev->name, dev->base_addr, dev->dev_addr,
+			      dev->irq));
 	DEB(DEB_INIT, printk(KERN_INFO
 			     "%s: dma at 0x%p (%d bytes), lp->scb at 0x%p\n",
 			     dev->name, dma, (int)sizeof(struct i596_dma), 
