From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.4.30-rc3] pcnet32: 79C975 fiber fix
Date: Mon, 28 Mar 2005 12:13:22 -0800
Message-ID: <20050328201322.GA21428@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
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

--- linux-2.4.30-rc1/drivers/net/orig.pcnet32.c	Wed Jan 19 06:09:56 2005
+++ linux-2.4.30-rc1/drivers/net/pcnet32.c	Wed Mar 23 16:12:03 2005
@@ -1348,7 +1348,8 @@ pcnet32_probe1(unsigned long ioaddr, int
 	printk(KERN_INFO "%s: registered as %s\n", dev->name, lp->name);
     cards_found++;
 
-    a->write_bcr(ioaddr, 2, 0x1002);	/* enable LED writes */
+    /* enable LED writes */
+    a->write_bcr(ioaddr, 2, a->read_bcr(ioaddr, 2) | 0x1000);
 
     return 0;
 

-- 
Don Fry
brazilnut@us.ibm.com
