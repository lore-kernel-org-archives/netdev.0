From: Paul Gortmaker <p_gortmaker@yahoo.com>
Subject: [PATCH] ne2k_cbus tidy up
Date: Mon, 22 Sep 2003 22:04:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F6FAA29.4070909@yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080802010301030704050609"
Cc: Jeff Garzik <jgarzik@pobox.com>, Donald Becker <becker@scyld.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080802010301030704050609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

When Osamu Tomita cloned ne2k_cbus from the ISA ne.c,
some of the version information, printks and so on were
not updated to reflect that it was indeed a different
driver than the original.  This tidy up takes care of
that and zaps the old changelog info which is no longer
relevant.

Patch is against 2.6.0-test5.

Thanks,
Paul.


--------------080802010301030704050609
Content-Type: text/plain;
 name="2.6.0-test5-ne2k_cbus-diff0"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="2.6.0-test5-ne2k_cbus-diff0"

--- linux/drivers/net/ne2k_cbus.c	Mon Mar 24 14:02:10 2003
+++ linux-net/drivers/net/ne2k_cbus.c	Mon Sep 22 21:45:32 2003
@@ -1,45 +1,26 @@
-/* ne.c: A general non-shared-memory NS8390 ethernet driver for linux. */
 /*
-    Written 1992-94 by Donald Becker.
 
+  ne2k_cbus.c: A driver for the NE2000 like ethernet on NEC PC-9800.
+
+	This is a copy of the 2.5.66 Linux ISA NE2000 driver "ne.c" 
+	(Donald Becker/Paul Gortmaker) with the NEC PC-9800 specific
+	changes added by Osamu Tomita. 
+
+From ne.c:
+-----------
     Copyright 1993 United States Government as represented by the
     Director, National Security Agency.
 
     This software may be used and distributed according to the terms
     of the GNU General Public License, incorporated herein by reference.
-
-    The author may be reached as becker@scyld.com, or C/O
-    Scyld Computing Corporation, 410 Severn Ave., Suite 210, Annapolis MD 21403
-
-    This driver should work with many programmed-I/O 8390-based ethernet
-    boards.  Currently it supports the NE1000, NE2000, many clones,
-    and some Cabletron products.
-
-    Changelog:
-
-    Paul Gortmaker	: use ENISR_RDC to monitor Tx PIO uploads, made
-			  sanity checks and bad clone support optional.
-    Paul Gortmaker	: new reset code, reset card after probe at boot.
-    Paul Gortmaker	: multiple card support for module users.
-    Paul Gortmaker	: Support for PCI ne2k clones, similar to lance.c
-    Paul Gortmaker	: Allow users with bad cards to avoid full probe.
-    Paul Gortmaker	: PCI probe changes, more PCI cards supported.
-    rjohnson@analogic.com : Changed init order so an interrupt will only
-    occur after memory is allocated for dev->priv. Deallocated memory
-    last in cleanup_modue()
-    Richard Guenther    : Added support for ISAPnP cards
-    Paul Gortmaker	: Discontinued PCI support - use ne2k-pci.c instead.
-    Osamu Tomita	: Separate driver for NEC PC-9800.
+-----------
 
 */
 
 /* Routines for the NatSemi-based designs (NE[12]000). */
 
-static const char version1[] =
-"ne.c:v1.10 9/23/94 Donald Becker (becker@scyld.com)\n";
-static const char version2[] =
-"Last modified Nov 1, 2000 by Paul Gortmaker\n";
-
+static const char version[] =
+"ne2k_cbus.c:v1.0 3/24/03 Osamu Tomita\n";
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -273,7 +254,7 @@
 	}
 
 	if (ei_debug  &&  version_printed++ == 0)
-		printk(KERN_INFO "%s" KERN_INFO "%s", version1, version2);
+		printk(KERN_INFO "%s", version);
 
 	printk(KERN_INFO "NE*000 ethercard probe at %#3x:", ioaddr);
 
@@ -839,9 +820,9 @@
 			return 0;
 		}
 		if (io[this_dev] != 0)
-			printk(KERN_WARNING "ne.c: No NE*000 card found at i/o = %#x\n", io[this_dev]);
+			printk(KERN_WARNING "ne2k_cbus: No NE*000 card found at i/o = %#x\n", io[this_dev]);
 		else
-			printk(KERN_NOTICE "ne.c: You must supply \"io=0xNNN\" value(s) for C-Bus cards.\n");
+			printk(KERN_NOTICE "ne2k_cbus: You must supply \"io=0xNNN\" value(s) for C-Bus cards.\n");
 		return -ENXIO;
 	}
 	return 0;
@@ -869,11 +850,3 @@
 }
 #endif /* MODULE */
 
-
-/*
- * Local variables:
- *  compile-command: "gcc -DKERNEL -Wall -O6 -fomit-frame-pointer -I/usr/src/linux/net/tcp -c ne.c"
- *  version-control: t
- *  kept-new-versions: 5
- * End:
- */

--------------080802010301030704050609--
