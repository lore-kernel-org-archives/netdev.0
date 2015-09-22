From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 11/33] arcnet: Convert printk to pr_<level>
Date: Tue, 22 Sep 2015 11:01:52 +0200
Message-ID: <1442912534-10821-12-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35105 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932487AbbIVJCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:41 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Use the more current logging style.

Remove #define VERSION, use pr_info normally.
Add pr_fmt with "arcnet:" prefixes and KBUILD_MODNAME.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rawmode.c  |  6 +++---
 drivers/net/arcnet/arc-rimi.c     | 21 +++++++++++----------
 drivers/net/arcnet/arcnet.c       | 25 ++++++++-----------------
 drivers/net/arcnet/capmode.c      |  6 +++---
 drivers/net/arcnet/com20020-isa.c |  9 +++++----
 drivers/net/arcnet/com20020-pci.c |  9 +++++----
 drivers/net/arcnet/com20020.c     |  7 ++++---
 drivers/net/arcnet/com20020_cs.c  |  5 +++--
 drivers/net/arcnet/com90io.c      | 11 ++++++-----
 drivers/net/arcnet/com90xx.c      | 17 +++++++++--------
 drivers/net/arcnet/rfc1051.c      |  7 ++++---
 drivers/net/arcnet/rfc1201.c      |  6 ++++--
 12 files changed, 65 insertions(+), 64 deletions(-)

diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index 034c898..e4a2702 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -24,6 +24,8 @@
  * **********************
  */
 
+#define pr_fmt(fmt) "arcnet:" KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/gfp.h>
 #include <linux/init.h>
@@ -33,8 +35,6 @@
 #include <linux/skbuff.h>
 #include <linux/arcdevice.h>
 
-#define VERSION "arcnet: raw mode (`r') encapsulation support loaded.\n"
-
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length);
 static int build_header(struct sk_buff *skb, struct net_device *dev,
@@ -56,7 +56,7 @@ static int __init arcnet_raw_init(void)
 {
 	int count;
 
-	printk(VERSION);
+	pr_info("%s\n", "raw mode (`r') encapsulation support loaded");
 
 	for (count = 0; count < 256; count++)
 		if (arc_proto_map[count] == arc_proto_default)
diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index 25f84b7..7360214 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -24,6 +24,9 @@
  *
  * **********************
  */
+
+#define pr_fmt(fmt) "arcnet:" KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
@@ -36,8 +39,6 @@
 #include <linux/io.h>
 #include <linux/arcdevice.h>
 
-#define VERSION "arcnet: RIM I (entirely mem-mapped) support\n"
-
 /* Internal function declarations */
 
 static int arcrimi_probe(struct net_device *dev);
@@ -83,20 +84,20 @@ static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offse
 static int __init arcrimi_probe(struct net_device *dev)
 {
 	if (BUGLVL(D_NORMAL)) {
-		printk(VERSION);
-		printk("E-mail me if you actually test the RIM I driver, please!\n");
-		printk("Given: node %02Xh, shmem %lXh, irq %d\n",
-		       dev->dev_addr[0], dev->mem_start, dev->irq);
+		pr_info("%s\n", "RIM I (entirely mem-mapped) support");
+		pr_info("E-mail me if you actually test the RIM I driver, please!\n");
+		pr_info("Given: node %02Xh, shmem %lXh, irq %d\n",
+			dev->dev_addr[0], dev->mem_start, dev->irq);
 	}
 
 	if (dev->mem_start <= 0 || dev->irq <= 0) {
 		if (BUGLVL(D_NORMAL))
-			printk("No autoprobe for RIM I; you must specify the shmem and irq!\n");
+			pr_err("No autoprobe for RIM I; you must specify the shmem and irq!\n");
 		return -ENODEV;
 	}
 	if (dev->dev_addr[0] == 0) {
 		if (BUGLVL(D_NORMAL))
-			printk("You need to specify your card's station ID!\n");
+			pr_err("You need to specify your card's station ID!\n");
 		return -ENODEV;
 	}
 	/* Grab the memory region at mem_start for MIRROR_SIZE bytes.
@@ -106,7 +107,7 @@ static int __init arcrimi_probe(struct net_device *dev)
 	 */
 	if (!request_mem_region(dev->mem_start, MIRROR_SIZE, "arcnet (90xx)")) {
 		if (BUGLVL(D_NORMAL))
-			printk("Card memory already allocated\n");
+			pr_notice("Card memory already allocated\n");
 		return -ENODEV;
 	}
 	return arcrimi_found(dev);
@@ -375,7 +376,7 @@ static int __init arcrimi_setup(char *s)
 		return 1;
 	switch (ints[0]) {
 	default:		/* ERROR */
-		printk("arcrimi: Too many arguments.\n");
+		pr_err("Too many arguments\n");
 	case 3:		/* Node ID */
 		node = ints[3];
 	case 2:		/* IRQ */
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 2aab7e2..2be8ab6 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -41,7 +41,7 @@
  *     <jojo@repas.de>
  */
 
-#define VERSION "arcnet: v3.94 BETA 2007/02/08 - by Avery Pennarun et al.\n"
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/module.h>
 #include <linux/types.h>
@@ -114,18 +114,7 @@ static int __init arcnet_init(void)
 
 	arcnet_debug = debug;
 
-	printk("arcnet loaded.\n");
-
-#ifdef ALPHA_WARNING
-	if (BUGLVL(D_EXTRA)) {
-		printk("arcnet: ***\n"
-		"arcnet: * Read arcnet.txt for important release notes!\n"
-		       "arcnet: *\n"
-		       "arcnet: * This is an ALPHA version! (Last stable release: v3.02)  E-mail\n"
-		       "arcnet: * me if you have any questions, comments, or bug reports.\n"
-		       "arcnet: ***\n");
-	}
-#endif
+	pr_info("arcnet loaded\n");
 
 	/* initialize the protocol map */
 	arc_raw_proto = arc_proto_default = arc_bcast_proto = &arc_proto_null;
@@ -133,10 +122,12 @@ static int __init arcnet_init(void)
 		arc_proto_map[count] = arc_proto_default;
 
 	if (BUGLVL(D_DURING))
-		printk("arcnet: struct sizes: %Zd %Zd %Zd %Zd %Zd\n",
-		       sizeof(struct arc_hardware), sizeof(struct arc_rfc1201),
-		       sizeof(struct arc_rfc1051), sizeof(struct arc_eth_encap),
-		       sizeof(struct archdr));
+		pr_info("struct sizes: %Zd %Zd %Zd %Zd %Zd\n",
+			sizeof(struct arc_hardware),
+			sizeof(struct arc_rfc1201),
+			sizeof(struct arc_rfc1051),
+			sizeof(struct arc_eth_encap),
+			sizeof(struct archdr));
 
 	return 0;
 }
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index d62d1ac..92b553e 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -26,6 +26,8 @@
  * **********************
  */
 
+#define pr_fmt(fmt) "arcnet:" KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/gfp.h>
 #include <linux/init.h>
@@ -35,8 +37,6 @@
 #include <linux/skbuff.h>
 #include <linux/arcdevice.h>
 
-#define VERSION "arcnet: cap mode (`c') encapsulation support loaded.\n"
-
 /* packet receiver */
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
@@ -259,7 +259,7 @@ static void arcnet_cap_init(void)
 
 static int __init capmode_module_init(void)
 {
-	printk(VERSION);
+	pr_info("%s\n", "cap mode (`c') encapsulation support loaded");
 	arcnet_cap_init();
 	return 0;
 }
diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index c3748f7..f3b2222 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -25,6 +25,9 @@
  *
  * **********************
  */
+
+#define pr_fmt(fmt) "arcnet:" KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/kernel.h>
@@ -41,8 +44,6 @@
 
 #include <linux/io.h>
 
-#define VERSION "arcnet: COM20020 ISA support (by David Woodhouse et al.)\n"
-
 /* We cannot (yet) probe for an IO mapped card, although we can check that
  * it's where we were told it was, and even do autoirq.
  */
@@ -54,7 +55,7 @@ static int __init com20020isa_probe(struct net_device *dev)
 	int err;
 
 	if (BUGLVL(D_NORMAL))
-		printk(VERSION);
+		pr_info("%s\n", "COM20020 ISA support (by David Woodhouse et al.)");
 
 	ioaddr = dev->base_addr;
 	if (!ioaddr) {
@@ -193,7 +194,7 @@ static int __init com20020isa_setup(char *s)
 
 	switch (ints[0]) {
 	default:		/* ERROR */
-		printk("com90xx: Too many arguments.\n");
+		pr_info("Too many arguments\n");
 	case 6:		/* Timeout */
 		timeout = ints[6];
 	case 5:		/* CKP value */
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 0d0cc6a..7247add 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -26,6 +26,9 @@
  *
  * **********************
  */
+
+#define pr_fmt(fmt) "arcnet:" KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/kernel.h>
@@ -42,8 +45,6 @@
 
 #include <linux/io.h>
 
-#define VERSION "arcnet: COM20020 PCI support\n"
-
 /* Module parameters */
 
 static int node;
@@ -105,7 +106,7 @@ static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *i
 		r = devm_request_region(&pdev->dev, ioaddr, cm->size,
 					"com20020-pci");
 		if (!r) {
-			pr_err("IO region %xh-%xh already allocated.\n",
+			pr_err("IO region %xh-%xh already allocated\n",
 			       ioaddr, ioaddr + cm->size - 1);
 			ret = -EBUSY;
 			goto out_port;
@@ -403,7 +404,7 @@ static struct pci_driver com20020pci_driver = {
 static int __init com20020pci_init(void)
 {
 	if (BUGLVL(D_NORMAL))
-		printk(VERSION);
+		pr_info("%s\n", "COM20020 PCI support");
 	return pci_register_driver(&com20020pci_driver);
 }
 
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index b0b8a0b..e813fc6 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -25,6 +25,9 @@
  *
  * **********************
  */
+
+#define pr_fmt(fmt) "arcnet:" KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
@@ -39,8 +42,6 @@
 
 #include <linux/io.h>
 
-#define VERSION "arcnet: COM20020 chipset support (by David Woodhouse et al.)\n"
-
 static char *clockrates[] = {
 	"XXXXXXX", "XXXXXXXX", "XXXXXX",
 	"2.5 Mb/s", "1.25Mb/s", "625 Kb/s", "312.5 Kb/s",
@@ -368,7 +369,7 @@ MODULE_LICENSE("GPL");
 static int __init com20020_module_init(void)
 {
 	if (BUGLVL(D_NORMAL))
-		printk(VERSION);
+		pr_info("%s\n", "COM20020 chipset support (by David Woodhouse et al.)\n");
 	return 0;
 }
 
diff --git a/drivers/net/arcnet/com20020_cs.c b/drivers/net/arcnet/com20020_cs.c
index 13fe538..8541694 100644
--- a/drivers/net/arcnet/com20020_cs.c
+++ b/drivers/net/arcnet/com20020_cs.c
@@ -31,6 +31,9 @@
  *
  * **********************
  */
+
+#define pr_fmt(fmt) "arcnet:" KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/ptrace.h>
 #include <linux/slab.h>
@@ -47,8 +50,6 @@
 
 #include <linux/io.h>
 
-#define VERSION "arcnet: COM20020 PCMCIA support loaded.\n"
-
 static void regdump(struct net_device *dev)
 {
 #ifdef DEBUG
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index ec2db85..32abaa8 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -25,6 +25,9 @@
  *
  * **********************
  */
+
+#define pr_fmt(fmt) "arcnet:" KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
@@ -37,8 +40,6 @@
 #include <linux/io.h>
 #include <linux/arcdevice.h>
 
-#define VERSION "arcnet: COM90xx IO-mapped mode support (by David Woodhouse et el.)\n"
-
 /* Internal function declarations */
 
 static int com90io_found(struct net_device *dev);
@@ -146,8 +147,8 @@ static int __init com90io_probe(struct net_device *dev)
 	unsigned long airqmask;
 
 	if (BUGLVL(D_NORMAL)) {
-		printk(VERSION);
-		printk("E-mail me if you actually test this driver, please!\n");
+		pr_info("%s\n", "COM90xx IO-mapped mode support (by David Woodhouse et el.)");
+		pr_info("E-mail me if you actually test this driver, please!\n");
 	}
 
 	if (!ioaddr) {
@@ -369,7 +370,7 @@ static int __init com90io_setup(char *s)
 		return 0;
 	switch (ints[0]) {
 	default:		/* ERROR */
-		printk("com90io: Too many arguments.\n");
+		pr_err("Too many arguments\n");
 	case 2:		/* IRQ */
 		irq = ints[2];
 	case 1:		/* IO address */
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index 12534a3..50c346b 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -24,6 +24,9 @@
  *
  * **********************
  */
+
+#define pr_fmt(fmt) "arcnet:" KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/init.h>
@@ -35,8 +38,6 @@
 #include <linux/io.h>
 #include <linux/arcdevice.h>
 
-#define VERSION "arcnet: COM90xx chipset support\n"
-
 /* Define this to speed up the autoprobe by assuming if only one io port and
  * shmem are left in the list at Stage 5, they must correspond to each
  * other.
@@ -134,7 +135,7 @@ static void __init com90xx_probe(void)
 	}
 
 	if (BUGLVL(D_NORMAL))
-		printk(VERSION);
+		pr_info("%s\n", "COM90xx chipset support");
 
 	/* set up the arrays where we'll store the possible probe addresses */
 	numports = numshmems = 0;
@@ -418,9 +419,9 @@ static void __init com90xx_probe(void)
 
 		if (openparen) {
 			if (BUGLVL(D_INIT))
-				printk("no matching shmem)\n");
+				pr_cont("no matching shmem)\n");
 			if (BUGLVL(D_INIT_REASONS)) {
-				printk("S5: ");
+				pr_cont("S5: ");
 				numprint = 0;
 			}
 		}
@@ -430,7 +431,7 @@ static void __init com90xx_probe(void)
 	}
 
 	if (BUGLVL(D_INIT_REASONS))
-		printk("\n");
+		pr_cont("\n");
 
 	/* Now put back TESTvalue on all leftover shmems. */
 	for (index = 0; index < numshmems; index++) {
@@ -685,13 +686,13 @@ static int __init com90xx_setup(char *s)
 
 	s = get_options(s, 8, ints);
 	if (!ints[0] && !*s) {
-		printk("com90xx: Disabled.\n");
+		pr_notice("Disabled\n");
 		return 1;
 	}
 
 	switch (ints[0]) {
 	default:		/* ERROR */
-		printk("com90xx: Too many arguments.\n");
+		pr_err("Too many arguments\n");
 	case 3:		/* Mem address */
 		shmem = ints[3];
 	case 2:		/* IRQ */
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index 47c7d1a..d5a0f90 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -23,6 +23,9 @@
  *
  * **********************
  */
+
+#define pr_fmt(fmt) "arcnet:" KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/gfp.h>
 #include <linux/init.h>
@@ -32,8 +35,6 @@
 #include <linux/skbuff.h>
 #include <linux/arcdevice.h>
 
-#define VERSION "arcnet: RFC1051 \"simple standard\" (`s') encapsulation support loaded.\n"
-
 static __be16 type_trans(struct sk_buff *skb, struct net_device *dev);
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length);
@@ -55,7 +56,7 @@ static struct ArcProto rfc1051_proto = {
 
 static int __init arcnet_rfc1051_init(void)
 {
-	printk(VERSION);
+	pr_info("%s\n", "RFC1051 \"simple standard\" (`s') encapsulation support loaded");
 
 	arc_proto_map[ARC_P_IP_RFC1051]
 	    = arc_proto_map[ARC_P_ARP_RFC1051]
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index 97af7d9..3dae141 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -23,6 +23,9 @@
  *
  * **********************
  */
+
+#define pr_fmt(fmt) "arcnet:" KBUILD_MODNAME ": " fmt
+
 #include <linux/gfp.h>
 #include <linux/module.h>
 #include <linux/init.h>
@@ -32,7 +35,6 @@
 #include <linux/arcdevice.h>
 
 MODULE_LICENSE("GPL");
-#define VERSION "arcnet: RFC1201 \"standard\" (`a') encapsulation support loaded.\n"
 
 static __be16 type_trans(struct sk_buff *skb, struct net_device *dev);
 static void rx(struct net_device *dev, int bufnum,
@@ -56,7 +58,7 @@ static struct ArcProto rfc1201_proto = {
 
 static int __init arcnet_rfc1201_init(void)
 {
-	printk(VERSION);
+	pr_info("%s\n", "RFC1201 \"standard\" (`a') encapsulation support loaded");
 
 	arc_proto_map[ARC_P_IP]
 	    = arc_proto_map[ARC_P_IPV6]
-- 
2.5.1
