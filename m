From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] networking/cs89x0.txt: delete stale information about hand patching
Date: Fri, 11 Jan 2013 19:19:36 -0500
Message-ID: <1357949976-11463-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57740 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755031Ab3ALATr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 19:19:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Output of a git grep happened to make me look into this file, and
I found instructions about how to hand patch (without using patch)
the driver into the kernel tree.

Since the driver has been a part of the mainline kernel for years,
we can dump this whole section.  Fortunately it doesn't even cause
a renumbering of the sections to do so.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 Documentation/networking/cs89x0.txt | 78 -------------------------------------
 1 file changed, 78 deletions(-)

diff --git a/Documentation/networking/cs89x0.txt b/Documentation/networking/cs89x0.txt
index c725d33..2ede91f 100644
--- a/Documentation/networking/cs89x0.txt
+++ b/Documentation/networking/cs89x0.txt
@@ -364,84 +364,6 @@ The compile-time optionality for DMA was removed in the 2.3 kernel
 series.  DMA support is now unconditionally part of the driver.  It is
 enabled by the 'use_dma=1' module option.
 
-4.4 COMPILING THE DRIVER INTO THE KERNEL
-
-If your Linux distribution already has support for the cs89x0 driver
-then simply copy the source file to the /usr/src/linux/drivers/net
-directory to replace the original ones and run the make utility to
-rebuild the kernel.  See Step 3 for rebuilding the kernel.
-
-If your Linux does not include the cs89x0 driver, you need to edit three 
-configuration files, copy the source file to the /usr/src/linux/drivers/net
-directory, and then run the make utility to rebuild the kernel.
-
-1. Edit the following configuration files by adding the statements as
-indicated.  (When possible, try to locate the added text to the section of the
-file containing similar statements).
-
-
-a.) In /usr/src/linux/drivers/net/Config.in, add:
-
-tristate 'CS89x0 support' CONFIG_CS89x0
-
-Example:
-
-     if [ "$CONFIG_EXPERIMENTAL" = "y" ]; then
-       tristate 'ICL EtherTeam 16i/32 support' CONFIG_ETH16I
-     fi
-
-     tristate 'CS89x0 support' CONFIG_CS89x0
-
-     tristate 'NE2000/NE1000 support' CONFIG_NE2000
-     if [ "$CONFIG_EXPERIMENTAL" = "y" ]; then
-       tristate 'NI5210 support' CONFIG_NI52
-
-
-b.) In /usr/src/linux/drivers/net/Makefile, add the following lines: 
-
-ifeq ($(CONFIG_CS89x0),y)
-L_OBJS += cs89x0.o
-else
-  ifeq ($(CONFIG_CS89x0),m)
-  M_OBJS += cs89x0.o
-  endif
-endif
-
-
-c.) In /linux/drivers/net/Space.c file, add the line:
-
-extern int cs89x0_probe(struct device *dev);
-
-
-Example:
-
- extern int ultra_probe(struct device *dev);
- extern int wd_probe(struct device *dev);
- extern int el2_probe(struct device *dev);
-
- extern int cs89x0_probe(struct device *dev);
-
- extern int ne_probe(struct device *dev);
- extern int hp_probe(struct device *dev);
- extern int hp_plus_probe(struct device *dev);
-
-
-Also add:
-
- #ifdef CONFIG_CS89x0
- 	{ cs89x0_probe,0 },
- #endif
-
-
-2.) Copy the driver source files (cs89x0.c and cs89x0.h) 
-into the /usr/src/linux/drivers/net directory.
-
-
-3.) Go to /usr/src/linux directory and run 'make config' followed by 'make' 
-(or make bzImage) to rebuild the kernel. 
-
-4.) Use the DOS 'setup' utility to disable plug and play on the NIC.
-
 
 5.0 TESTING AND TROUBLESHOOTING
 ===============================================================================
-- 
1.8.1
