From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.12-rc1] pcnet32: 79C975 fiber fix
Date: Mon, 28 Mar 2005 12:10:24 -0800
Message-ID: <20050328201024.GA21408@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        steven.hardy@astrium.eads.net
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "HARDY, Steven" <steven.hardy@astrium.eads.net>

I have found a bug in the pcnet32 driver (drivers/net/pcnet32.c)
affecting all ethernet cards based on the AMD79C975 chip, using the
fiber interface.

It's a one line fix, where some config registers get corrupted during
initialisation (which stops the Fiber interface working with this chip)

This bug was introduced somewhere betweeen 2.4.17 and 2.6.x (noticed
whilst upgrading to 2.6), and it may affect other chips too.  I have
checked all versions up to 2.6.11-bk6 and they are all broken.

Signed-off-by: Andrew Morton <akpm@osdl.org>
Signed-off-by: Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.12-rc1-bk1/drivers/net/orig.pcnet32.c	2005-03-23 10:19:04.000000000 -0800
+++ linux-2.6.12-rc1-bk1/drivers/net/pcnet32.c	2005-03-23 11:03:22.000000000 -0800
@@ -1351,7 +1351,8 @@ pcnet32_probe1(unsigned long ioaddr, int
 	printk(KERN_INFO "%s: registered as %s\n", dev->name, lp->name);
     cards_found++;
 
-    a->write_bcr(ioaddr, 2, 0x1002);	/* enable LED writes */
+    /* enable LED writes */
+    a->write_bcr(ioaddr, 2, a->read_bcr(ioaddr, 2) | 0x1000);
 
     return 0;
 
-- 
Don Fry
brazilnut@us.ibm.com
