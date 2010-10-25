From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH 1/2] be2net: Call netif_carier_off() after register_netdev()
Date: Mon, 25 Oct 2010 16:41:10 +0530
Message-ID: <20101025111110.GA1990@emulex.com>
Reply-To: Somnath Kotur <somnath.kotur@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:44721 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751262Ab0JYLLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 07:11:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling netif_carrier_off before register_netdev was causing the network interface
to miss a linkwatch pending event leading to  an inconsistent state if the link
is not up when interface is initialized.This is now invoked after register_netdev.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 1248626..8767355 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2556,7 +2556,6 @@ static void be_netdev_init(struct net_device *netdev)
 	netif_napi_add(netdev, &adapter->tx_eq.napi, be_poll_tx_mcc,
 		BE_NAPI_WEIGHT);
 
-	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 }
 
@@ -2865,6 +2864,7 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	status = register_netdev(netdev);
 	if (status != 0)
 		goto unsetup;
+	netif_carrier_off(netdev);
 
 	dev_info(&pdev->dev, "%s port %d\n", nic_name(pdev), adapter->port_num);
 	return 0;
-- 
1.5.6.1

