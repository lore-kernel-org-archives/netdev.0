From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 27/45] olympic: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:24 -0800
Message-ID: <20090109230138.704718826@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42222 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754255AbZAIXR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:58 -0500
Content-Disposition: inline; filename=olympic-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tokenring/olympic.c	2009-01-09 13:59:50.000000000 -0800
+++ b/drivers/net/tokenring/olympic.c	2009-01-09 14:00:26.000000000 -0800
@@ -194,6 +194,15 @@ static void olympic_srb_bh(struct net_de
 static void olympic_asb_bh(struct net_device *dev) ; 
 static int olympic_proc_info(char *buffer, char **start, off_t offset, int length, int *eof, void *data) ; 
 
+static const struct net_device_ops olympic_netdev_ops = {
+	.ndo_open		= olympic_open,
+	.ndo_stop		= olympic_close,
+	.ndo_start_xmit		= olympic_xmit,
+	.ndo_change_mtu		= olympic_change_mtu,
+	.ndo_set_multicast_list	= olympic_set_rx_mode,
+	.ndo_set_mac_address	= olympic_set_mac_address,
+};
+
 static int __devinit olympic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev ; 
@@ -252,13 +261,7 @@ static int __devinit olympic_probe(struc
 		goto op_free_iomap;
 	}				
 
-	dev->open=&olympic_open;
-	dev->hard_start_xmit=&olympic_xmit;
-	dev->change_mtu=&olympic_change_mtu;
-	dev->stop=&olympic_close;
-	dev->do_ioctl=NULL;
-	dev->set_multicast_list=&olympic_set_rx_mode;
-	dev->set_mac_address=&olympic_set_mac_address ;  
+	dev->netdev_ops = &olympic_netdev_ops;
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	pci_set_drvdata(pdev,dev) ; 


