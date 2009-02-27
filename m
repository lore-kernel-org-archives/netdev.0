From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] net: fix hp-plus build error
Date: Thu, 26 Feb 2009 20:22:03 -0800
Message-ID: <49A76A6B.7020709@oracle.com>
References: <20090224212949.0dacb59f.sfr@canb.auug.org.au> <49A4248F.6090202@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	akpm <akpm@linux-foundation.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <49A4248F.6090202@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

hp-plus needs to call __alloc_eip_netdev() instead of
__alloc_ei_netdev() since it is linked with 8390p.o.

Fixes this build error:
ERROR: "__alloc_ei_netdev" [drivers/net/hp-plus.ko] undefined!

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/hp-plus.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mmotm-2009-0226-1658.orig/drivers/net/hp-plus.c
+++ mmotm-2009-0226-1658/drivers/net/hp-plus.c
@@ -467,7 +467,7 @@ init_module(void)
 			if (this_dev != 0) break; /* only autoprobe 1st one */
 			printk(KERN_NOTICE "hp-plus.c: Presently autoprobing (not recommended) for a single card.\n");
 		}
-		dev = alloc_ei_netdev();
+		dev = alloc_eip_netdev();
 		if (!dev)
 			break;
 		dev->irq = irq[this_dev];
