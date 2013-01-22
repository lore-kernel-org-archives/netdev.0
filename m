From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 14/15] drivers/net: delete Digital EtherWorks-3 support.
Date: Mon, 21 Jan 2013 20:46:21 -0500
Message-ID: <1358819182-28032-15-git-send-email-paul.gortmaker@windriver.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45375 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753053Ab3AVBqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 20:46:42 -0500
In-Reply-To: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is another one that makes sense to target for obsolescence, since
it (a)appeared pre-1995, and (b)was rather rare, and (c)did not
really have any statistically significant active linux user base.

Removing this ISA 10Mbit driver support is unlikely to be even noticed
by the user base of 3.9+ linux kernels, especially when the documentation
clearly indicates the vintage with this text:

	 "...designed to  work with all kernels > 1.1.33"

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 Documentation/networking/00-INDEX  |    2 -
 Documentation/networking/ewrk3.txt |   46 -
 drivers/net/Space.c                |    4 -
 drivers/net/ethernet/dec/Kconfig   |   16 -
 drivers/net/ethernet/dec/Makefile  |    1 -
 drivers/net/ethernet/dec/ewrk3.c   | 1961 ------------------------------------
 drivers/net/ethernet/dec/ewrk3.h   |  322 ------
 7 files changed, 2352 deletions(-)
 delete mode 100644 Documentation/networking/ewrk3.txt
 delete mode 100644 drivers/net/ethernet/dec/ewrk3.c
 delete mode 100644 drivers/net/ethernet/dec/ewrk3.h

diff --git a/Documentation/networking/00-INDEX b/Documentation/networking/00-INDEX
index 6ec1d6f..258d9b9 100644
--- a/Documentation/networking/00-INDEX
+++ b/Documentation/networking/00-INDEX
@@ -70,8 +70,6 @@ e1000e.txt
 	- README for the Intel Gigabit Ethernet Driver (e1000e).
 eql.txt
 	- serial IP load balancing
-ewrk3.txt
-	- the Digital EtherWORKS 3 DE203/4/5 Ethernet driver
 fib_trie.txt
 	- Level Compressed Trie (LC-trie) notes: a structure for routing.
 filter.txt
diff --git a/Documentation/networking/ewrk3.txt b/Documentation/networking/ewrk3.txt
deleted file mode 100644
index 90e9e5f..0000000
diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 393b017..9c30ea4 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -43,7 +43,6 @@ extern struct net_device *wd_probe(int unit);
 extern struct net_device *ne_probe(int unit);
 extern struct net_device *fmv18x_probe(int unit);
 extern struct net_device *i82596_probe(int unit);
-extern struct net_device *ewrk3_probe(int unit);
 extern struct net_device *ni65_probe(int unit);
 extern struct net_device *sonic_probe(int unit);
 extern struct net_device *seeq8005_probe(int unit);
@@ -122,9 +121,6 @@ static struct devprobe2 isa_probes[] __initdata = {
  	{cs89x0_probe, 0},
 #endif
 #endif
-#ifdef CONFIG_EWRK3             /* DEC EtherWORKS 3 */
-    	{ewrk3_probe, 0},
-#endif
 #if defined(CONFIG_MVME16x_NET) || defined(CONFIG_BVME6000_NET)	/* Intel I82596 */
 	{i82596_probe, 0},
 #endif
diff --git a/drivers/net/ethernet/dec/Kconfig b/drivers/net/ethernet/dec/Kconfig
index 3794027..68262aa 100644
--- a/drivers/net/ethernet/dec/Kconfig
+++ b/drivers/net/ethernet/dec/Kconfig
@@ -17,21 +17,5 @@ config NET_VENDOR_DEC
 	  your specific card in the following questions.
 
 if NET_VENDOR_DEC
-
-config EWRK3
-	tristate "EtherWORKS 3 (DE203, DE204, DE205) support"
-	depends on ISA
-	select CRC32
-	---help---
-	  This driver supports the DE203, DE204 and DE205 network (Ethernet)
-	  cards. If this is for you, say Y and read
-	  <file:Documentation/networking/ewrk3.txt> in the kernel source as
-	  well as the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ewrk3.
-
 source "drivers/net/ethernet/dec/tulip/Kconfig"
-
 endif # NET_VENDOR_DEC
diff --git a/drivers/net/ethernet/dec/Makefile b/drivers/net/ethernet/dec/Makefile
index 1b01ed8..32993fc 100644
--- a/drivers/net/ethernet/dec/Makefile
+++ b/drivers/net/ethernet/dec/Makefile
@@ -2,5 +2,4 @@
 # Makefile for the Digital Equipment Inc. network device drivers.
 #
 
-obj-$(CONFIG_EWRK3) += ewrk3.o
 obj-$(CONFIG_NET_TULIP) += tulip/
diff --git a/drivers/net/ethernet/dec/ewrk3.c b/drivers/net/ethernet/dec/ewrk3.c
deleted file mode 100644
index 5015172..0000000
diff --git a/drivers/net/ethernet/dec/ewrk3.h b/drivers/net/ethernet/dec/ewrk3.h
deleted file mode 100644
index 8e0ee90..0000000
-- 
1.8.1
