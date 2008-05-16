From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] 3c515: fix using pnp_get_resource when
 CONFIG_ISAPNP=n
Date: Fri, 16 May 2008 10:35:24 -0700
Message-ID: <20080516103524.0b00ffb6.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, bjorn.helgaas@hp.com,
	akpm <akpm@linux-foundation.org>
To: netdev <netdev@vger.kernel.org>, jgarzik <jgarzik@pobox.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

3c515.c uses pnp_irq(), which calls pnp_get_resource(),
which is not defined when CONFIG_PNP=n, so in that case,
get the IRQ from a hardware register.

3c515.c:(.text+0x3adc0): undefined reference to `pnp_get_resource'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/3c515.c |    4 ++++
 1 file changed, 4 insertions(+)

--- next-20080516.orig/drivers/net/3c515.c
+++ next-20080516/drivers/net/3c515.c
@@ -572,12 +572,16 @@ static int corkscrew_setup(struct net_de
 	int irq;
 	DECLARE_MAC_BUF(mac);
 
+#ifdef __ISAPNP__
 	if (idev) {
 		irq = pnp_irq(idev, 0);
 		vp->dev = &idev->dev;
 	} else {
 		irq = inw(ioaddr + 0x2002) & 15;
 	}
+#else
+	irq = inw(ioaddr + 0x2002) & 15;
+#endif
 
 	dev->base_addr = ioaddr;
 	dev->irq = irq;
