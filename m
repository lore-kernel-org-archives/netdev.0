From: akpm@osdl.org
Subject: [patch 12/13] pcnet32 79C975 fiber fix
Date: Tue, 15 Mar 2005 14:22:48 -0800
Message-ID: <200503152222.j2FMMiLB016826@shell0.pdx.osdl.net>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        steven.hardy@astrium.eads.net
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: "HARDY, Steven" <steven.hardy@astrium.eads.net>

I have found a bug in the pcnet32 driver (drivers/net/pcnet32.c) affecting
all ethernet cards based on the AMD79C975 chip, using the fiber interface.

It's a one line fix, where some config registers get corrupted during
initialisation (which stops the Fiber interface working with this chip)

This bug was introduced somewhere betweeen 2.4.17 and 2.6.x (noticed whilst
upgrading to 2.6), and it may affect other chips too.  I have checked all
versions up to 2.6.11-bk6 and they are all broken.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/pcnet32.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff -puN drivers/net/pcnet32.c~pcnet32-bug-79c975-fiber-fix drivers/net/pcnet32.c
--- 25/drivers/net/pcnet32.c~pcnet32-bug-79c975-fiber-fix	Tue Mar 15 14:19:55 2005
+++ 25-akpm/drivers/net/pcnet32.c	Tue Mar 15 14:19:55 2005
@@ -1351,7 +1351,8 @@ pcnet32_probe1(unsigned long ioaddr, int
 	printk(KERN_INFO "%s: registered as %s\n", dev->name, lp->name);
     cards_found++;
 
-    a->write_bcr(ioaddr, 2, 0x1002);	/* enable LED writes */
+    /* enable LED writes */
+    a->write_bcr(ioaddr, 2, a->read_bcr(ioaddr, 2) | 0x1002);
 
     return 0;
 
_
