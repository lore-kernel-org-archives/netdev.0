From: Borislav Petkov <bbpetkov@yahoo.de>
Subject: [PATCH] Olympic (IBM PCI tokenring): handle return codes of register_netdev
Date: Fri, 20 Apr 2007 08:52:32 +0200
Message-ID: <20070420065232.GA5165@zmei.tnic>
Reply-To: bbpetkov@yahoo.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@lists.osdl.org
To: linux-tr@linuxtr.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp109.plus.mail.re2.yahoo.com ([206.190.53.34]:41881 "HELO
	smtp109.plus.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1423030AbXDTGxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 02:53:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Handle return codes of register_netdev().

Signed-off-by: Borislav Petkov <bbpetkov@yahoo.de>


Index: 21-rc7/drivers/net/tokenring/olympic.c
===================================================================
--- 21-rc7.orig/drivers/net/tokenring/olympic.c
+++ 21-rc7/drivers/net/tokenring/olympic.c
@@ -264,7 +264,10 @@ static int __devinit olympic_probe(struc
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	pci_set_drvdata(pdev,dev) ; 
-	register_netdev(dev) ; 
+
+	if (register_netdev(dev))
+		goto op_free_iomap;
+
 	printk("Olympic: %s registered as: %s\n",olympic_priv->olympic_card_name,dev->name);
 	if (olympic_priv->olympic_network_monitor) { /* Must go after register_netdev as we need the device name */ 
 		char proc_name[20] ; 
@@ -281,7 +284,8 @@ op_free_iomap:
 	if (olympic_priv->olympic_lap)
 		iounmap(olympic_priv->olympic_lap);
 
-	free_netdev(dev);
+	if (dev)
+		free_netdev(dev);
 op_release_dev:
 	pci_release_regions(pdev); 
 
