From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Fix 64bit bugs in dscc44.c
Date: Tue, 7 Oct 2003 19:59:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007175953.GA1802@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ncorbic@sangoma.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


ioremap_nocache returns unsigned long, not u32. This makes a difference
on 64bit hosts.

-Andi

diff -u linux-2.5-cleanup/drivers/net/wan/dscc4.c-o linux-2.5-cleanup/drivers/net/wan/dscc4.c
--- linux-2.5-cleanup/drivers/net/wan/dscc4.c-o	2003-12-01 14:04:34.000000000 +0100
+++ linux-2.5-cleanup/drivers/net/wan/dscc4.c	2003-12-02 16:55:14.298508864 +0100
@@ -980,7 +980,7 @@
  *
  * This code doesn't need to be efficient. Keep It Simple
  */
-static void dscc4_pci_reset(struct pci_dev *pdev, u32 ioaddr)
+static void dscc4_pci_reset(struct pci_dev *pdev, unsigned long ioaddr)
 {
 	int i;
 
@@ -1461,7 +1461,8 @@
 	struct dscc4_dev_priv *root = token;
 	struct dscc4_pci_priv *priv;
 	struct net_device *dev;
-	u32 ioaddr, state;
+	unsigned long ioaddr;
+	u32 state;
 	unsigned long flags;
 	int i, handled = 1;
 
@@ -1613,7 +1614,7 @@
 				goto try;
 		}
 		if (state & Xpr) {
-			u32 scc_addr, ring;
+			unsigned long scc_addr, ring;
 			int i;
 
 			/*
@@ -1954,7 +1955,7 @@
 {
 	struct dscc4_pci_priv *ppriv;
 	struct dscc4_dev_priv *root;
-	u32 ioaddr;
+	unsigned long ioaddr;
 	int i;
 
 	ppriv = pci_get_drvdata(pdev);
