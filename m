From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] depca: release resources on errors
Date: Sat, 24 Jan 2004 22:31:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124223109.1c134ca1.rddunlap@osdl.org>
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

From: Leann Ogasawara <ogasawara@osdl.org>


Hi All,

Inserts missing iounmap's and release_mem_region's.  Appreciate
feedback.

Leann

diffed against 2.6.1  

===== drivers/net/depca.c 1.20 vs edited =====

diff -puN drivers/net/depca.c~depca_iounmap drivers/net/depca.c

diff -puN drivers/net/depca.c~depca_iounmap drivers/net/depca.c


 linux-262-rc1-bk1-rddunlap/drivers/net/depca.c |    4 ++++
 1 files changed, 4 insertions(+)

diff -puN drivers/net/depca.c~depca_iounmap drivers/net/depca.c
--- linux-262-rc1-bk1/drivers/net/depca.c~depca_iounmap	2004-01-23 15:49:48.000000000 -0800
+++ linux-262-rc1-bk1-rddunlap/drivers/net/depca.c	2004-01-23 15:49:48.000000000 -0800
@@ -771,6 +771,8 @@ static int __init depca_hw_init (struct 
 		status = -ENXIO;
 		if (!irqnum) {
 			printk(" and failed to detect IRQ line.\n");
+			iounmap(lp->sh_mem);
+			release_mem_region(mem_start, mem_len);
 			goto out_priv;
 		} else {
 			for (dev->irq = 0, i = 0; (depca_irq[i]) && (!dev->irq); i++)
@@ -781,6 +783,8 @@ static int __init depca_hw_init (struct 
 
 			if (!dev->irq) {
 				printk(" but incorrect IRQ line detected.\n");
+				iounmap(lp->sh_mem);
+				release_mem_region(mem_start, mem_len);
 				return -ENXIO;
 			}
 		}

_
