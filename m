From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/9] can: ems_usb: Removed double netif_device_detach
Date: Fri,  3 Feb 2012 01:51:50 +0100
Message-ID: <1328230318-8962-2-git-send-email-mkl@pengutronix.de>
References: <1328230318-8962-1-git-send-email-mkl@pengutronix.de>
Cc: Netdev@vger.kernel.org, kernel@pengutronix.de, mkl@blackshift.org,
	linux-can@vger.kernel.org, Sebastian Haas <dev@sebastianhaas.info>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56698 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754816Ab2BCAwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 19:52:05 -0500
In-Reply-To: <1328230318-8962-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Haas <dev@sebastianhaas.info>

netif_device_attched is called twice when ems_usb_start fails with -ENODEV

Signed-off-by: Sebastian Haas <dev@sebastianhaas.info>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/ems_usb.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index 9697c14..7dae64d 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -627,9 +627,6 @@ static int ems_usb_start(struct ems_usb *dev)
 
 		err = usb_submit_urb(urb, GFP_KERNEL);
 		if (err) {
-			if (err == -ENODEV)
-				netif_device_detach(dev->netdev);
-
 			usb_unanchor_urb(urb);
 			usb_free_coherent(dev->udev, RX_BUFFER_SIZE, buf,
 					  urb->transfer_dma);
@@ -659,9 +656,6 @@ static int ems_usb_start(struct ems_usb *dev)
 
 	err = usb_submit_urb(dev->intr_urb, GFP_KERNEL);
 	if (err) {
-		if (err == -ENODEV)
-			netif_device_detach(dev->netdev);
-
 		dev_warn(netdev->dev.parent, "intr URB submit failed: %d\n",
 			 err);
 
@@ -692,9 +686,6 @@ static int ems_usb_start(struct ems_usb *dev)
 	return 0;
 
 failed:
-	if (err == -ENODEV)
-		netif_device_detach(dev->netdev);
-
 	dev_warn(netdev->dev.parent, "couldn't submit control: %d\n", err);
 
 	return err;
-- 
1.7.4.1
