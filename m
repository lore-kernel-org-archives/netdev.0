From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 21/26] pci-skeleton: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:55 +0400
Message-ID: <1239835980-22502-21-git-send-email-a.beregalov@gmail.com>
References: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-3-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-4-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-5-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-6-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-7-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-8-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-9-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-10-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-11-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-12-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-13-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-14-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-15-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-16-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-17-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-18-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-19-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-20-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:38008 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756661AbZDOWxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:31 -0400
Received: by bwz17 with SMTP id 17so114740bwz.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:28 -0700 (PDT)
In-Reply-To: <1239835980-22502-20-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/pci-skeleton.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index c95fd72..8c1f698 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -728,6 +728,17 @@ err_out:
 	return rc;
 }
 
+static const struct net_device_ops netdrv_netdev_ops = {
+	.ndo_open		= netdrv_open,
+	.ndo_stop		= netdrv_close,
+	.ndo_start_xmit		= netdrv_start_xmit,
+	.ndo_set_multicast_list	= netdrv_set_rx_mode,
+	.ndo_do_ioctl		= netdrv_ioctl,
+	.ndo_tx_timeout		= netdrv_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
 
 static int __devinit netdrv_init_one (struct pci_dev *pdev,
 				       const struct pci_device_id *ent)
@@ -769,13 +780,7 @@ static int __devinit netdrv_init_one (struct pci_dev *pdev,
 		((u16 *) (dev->dev_addr))[i] =
 		    le16_to_cpu (read_eeprom (ioaddr, i + 7, addr_len));
 
-	/* The Rtl8139-specific entries in the device structure. */
-	dev->open = netdrv_open;
-	dev->hard_start_xmit = netdrv_start_xmit;
-	dev->stop = netdrv_close;
-	dev->set_multicast_list = netdrv_set_rx_mode;
-	dev->do_ioctl = netdrv_ioctl;
-	dev->tx_timeout = netdrv_tx_timeout;
+	dev->netdev_ops = &netdrv_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	dev->irq = pdev->irq;
-- 
1.6.2.3

