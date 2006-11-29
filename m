From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 1/4] NetXen: Fixed /sys mapping between device and driver
Date: Wed, 29 Nov 2006 08:58:11 -0800
Message-ID: <200611291658.kATGwBuI023117@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:5445 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S935847AbWK2Q6M
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 11:58:12 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

 netxen_nic_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)


diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 145bf47..a055208 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -273,6 +273,7 @@ netxen_nic_probe(struct pci_dev *pdev, c
 		}
 
 		SET_MODULE_OWNER(netdev);
+		SET_NETDEV_DEV(netdev, &pdev->dev);
 
 		port = netdev_priv(netdev);
 		port->netdev = netdev;
@@ -1043,7 +1044,7 @@ static int netxen_nic_poll(struct net_de
 		netxen_nic_enable_int(adapter);
 	}
 
-	return (done ? 0 : 1);
+	return !done;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
