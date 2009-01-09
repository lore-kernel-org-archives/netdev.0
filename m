From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 29/45] 3c559: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:26 -0800
Message-ID: <20090109230138.854601842@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42224 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754260AbZAIXR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:58 -0500
Content-Disposition: inline; filename=tr-3com.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/tokenring/3c359.c	2009-01-05 16:38:58.165576860 -0800
+++ b/drivers/net/tokenring/3c359.c	2009-01-05 16:39:28.730569233 -0800
@@ -274,6 +274,15 @@ static void  xl_ee_write(struct net_devi
 	
 	return ; 
 }
+
+static const struct net_device_ops xl_netdev_ops = {
+	.ndo_open		= xl_open,
+	.ndo_stop		= xl_close,
+	.ndo_start_xmit		= xl_xmit,
+	.ndo_change_mtu		= xl_change_mtu,
+	.ndo_set_multicast_list = xl_set_rx_mode,
+	.ndo_set_mac_address	= xl_set_mac_address,
+};
  
 static int __devinit xl_probe(struct pci_dev *pdev,
 			      const struct pci_device_id *ent) 
@@ -337,13 +346,7 @@ static int __devinit xl_probe(struct pci
 		return i ; 
 	}				
 
-	dev->open=&xl_open;
-	dev->hard_start_xmit=&xl_xmit;
-	dev->change_mtu=&xl_change_mtu;
-	dev->stop=&xl_close;
-	dev->do_ioctl=NULL;
-	dev->set_multicast_list=&xl_set_rx_mode;
-	dev->set_mac_address=&xl_set_mac_address ; 
+	dev->netdev_ops = &xl_netdev_ops;
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	pci_set_drvdata(pdev,dev) ; 


