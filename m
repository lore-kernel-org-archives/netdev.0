From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next] networking/cs89x0.txt: delete stale information
 about hand patching
Date: Fri, 11 Jan 2013 19:45:58 -0500
Message-ID: <20130112004558.GB4625@windriver.com>
References: <1357949976-11463-1-git-send-email-paul.gortmaker@windriver.com>
 <20130111.163112.1015838278440673633.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63391 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753552Ab3ALAqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 19:46:00 -0500
Content-Disposition: inline
In-Reply-To: <20130111.163112.1015838278440673633.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH net-next] networking/cs89x0.txt: delete stale information about hand patching] On 11/01/2013 (Fri 16:31) David Miller wrote:

> From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Fri, 11 Jan 2013 19:19:36 -0500
> 
> > Output of a git grep happened to make me look into this file, and
> > I found instructions about how to hand patch (without using patch)
> > the driver into the kernel tree.
> > 
> > Since the driver has been a part of the mainline kernel for years,
> > we can dump this whole section.  Fortunately it doesn't even cause
> > a renumbering of the sections to do so.
> > 
> > Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> 
> When removing a section you should fix up the numbers of the
> remaining sections and any cross references within.

Ah crap, I was so glad that I didn't have to renumber anything, that
I did forget to delete the dangling TOC entry; thanks for spotting
that, and sorry for the v2 on something so trivial.

P.
--

>From d21b48a100d9c0e8f102b38a6e6dbeeb39f98b94 Mon Sep 17 00:00:00 2001
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 11 Jan 2013 19:00:36 -0500
Subject: [PATCH net-next v2] networking/cs89x0.txt: delete stale information
 about hand patching

Output of a git grep happened to make me look into this file, and
I found instructions about how to hand patch (without using patch)
the driver into the kernel tree.

Since the driver has been a part of the mainline kernel for years,
we can dump this whole section.  Fortunately it doesn't even cause
a renumbering of the sections to do so.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[v2: also delete the TOC entry for section 4.4]

 Documentation/networking/cs89x0.txt | 79 -------------------------------------
 1 file changed, 79 deletions(-)

diff --git a/Documentation/networking/cs89x0.txt b/Documentation/networking/cs89x0.txt
index c725d33..0e19018 100644
--- a/Documentation/networking/cs89x0.txt
+++ b/Documentation/networking/cs89x0.txt
@@ -36,7 +36,6 @@ TABLE OF CONTENTS
     4.1 Compiling the Driver as a Loadable Module
     4.2 Compiling the driver to support memory mode
     4.3 Compiling the driver to support Rx DMA 
-    4.4 Compiling the Driver into the Kernel
 
 5.0 TESTING AND TROUBLESHOOTING
     5.1 Known Defects and Limitations
@@ -364,84 +363,6 @@ The compile-time optionality for DMA was removed in the 2.3 kernel
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
