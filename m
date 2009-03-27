From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 09/30] tokenring: convert drivers to net_device_ops
Date: Thu, 26 Mar 2009 18:11:23 -0700
Message-ID: <20090327011255.602662418@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43175 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755466AbZC0B0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:26:08 -0400
Content-Disposition: inline; filename=tr-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert madge and proteon drivers which are really just subclasses
of tms380.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/tokenring/madgemc.c	2009-03-26 15:07:42.000000000 -0700
+++ b/drivers/net/tokenring/madgemc.c	2009-03-26 15:29:50.091370340 -0700
@@ -142,7 +142,7 @@ static void madgemc_sifwritew(struct net
 	return;
 }
 
-
+static struct net_device_ops madgemc_netdev_ops __read_mostly;
 
 static int __devinit madgemc_probe(struct device *device)
 {	
@@ -168,7 +168,7 @@ static int __devinit madgemc_probe(struc
 		goto getout;
 	}
 
-	dev->dma = 0;
+	dev->netdev_ops = &madgemc_netdev_ops;
 
 	card = kmalloc(sizeof(struct card_info), GFP_KERNEL);
 	if (card==NULL) {
@@ -348,9 +348,6 @@ static int __devinit madgemc_probe(struc
 
 	memcpy(tp->ProductID, "Madge MCA 16/4    ", PROD_ID_SIZE + 1);
 
-	dev->open = madgemc_open;
-	dev->stop = madgemc_close;
-
 	tp->tmspriv = card;
 	dev_set_drvdata(device, dev);
 
@@ -758,6 +755,10 @@ static struct mca_driver madgemc_driver 
 
 static int __init madgemc_init (void)
 {
+	madgemc_netdev_ops = tms380tr_netdev_ops;
+	madgemc_netdev_ops.ndo_open = madgemc_open;
+	madgemc_netdev_ops.ndo_stop = madgemc_close;
+
 	return mca_register_driver (&madgemc_driver);
 }
 
--- a/drivers/net/tokenring/proteon.c	2009-03-26 15:07:42.000000000 -0700
+++ b/drivers/net/tokenring/proteon.c	2009-03-26 15:19:12.931371862 -0700
@@ -116,6 +116,8 @@ nodev:
 	return -ENODEV;
 }
 
+static struct net_device_ops proteon_netdev_ops __read_mostly;
+
 static int __init setup_card(struct net_device *dev, struct device *pdev)
 {
 	struct net_local *tp;
@@ -167,8 +169,7 @@ static int __init setup_card(struct net_
 
 	tp->tmspriv = NULL;
 
-	dev->open = proteon_open;
-	dev->stop = tms380tr_close;
+	dev->netdev_ops = &proteon_netdev_ops;
 
 	if (dev->irq == 0)
 	{
@@ -352,6 +353,10 @@ static int __init proteon_init(void)
 	struct platform_device *pdev;
 	int i, num = 0, err = 0;
 
+	proteon_netdev_ops = tms380tr_netdev_ops;
+	proteon_netdev_ops.ndo_open = proteon_open;
+	proteon_netdev_ops.ndo_stop = tms380tr_close;
+
 	err = platform_driver_register(&proteon_driver);
 	if (err)
 		return err;
--- a/drivers/net/tokenring/skisa.c	2009-03-26 15:07:42.000000000 -0700
+++ b/drivers/net/tokenring/skisa.c	2009-03-26 15:19:47.558393173 -0700
@@ -133,6 +133,8 @@ static int __init sk_isa_probe1(struct n
 	return 0;
 }
 
+static struct net_device_ops sk_isa_netdev_ops __read_mostly;
+
 static int __init setup_card(struct net_device *dev, struct device *pdev)
 {
 	struct net_local *tp;
@@ -184,8 +186,7 @@ static int __init setup_card(struct net_
 
 	tp->tmspriv = NULL;
 
-	dev->open = sk_isa_open;
-	dev->stop = tms380tr_close;
+	dev->netdev_ops = &sk_isa_netdev_ops;
 
 	if (dev->irq == 0)
 	{
@@ -362,6 +363,10 @@ static int __init sk_isa_init(void)
 	struct platform_device *pdev;
 	int i, num = 0, err = 0;
 
+	sk_isa_netdev_ops = tms380tr_netdev_ops;
+	sk_isa_netdev_ops.ndo_open = sk_isa_open;
+	sk_isa_netdev_ops.ndo_stop = tms380tr_close;
+
 	err = platform_driver_register(&sk_isa_driver);
 	if (err)
 		return err;


