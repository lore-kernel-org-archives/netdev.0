From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 20/26] pasemi_mac: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:54 +0400
Message-ID: <1239835980-22502-20-git-send-email-a.beregalov@gmail.com>
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
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:50591 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756565AbZDOWx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:28 -0400
Received: by mail-bw0-f169.google.com with SMTP id 17so114640bwz.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:27 -0700 (PDT)
In-Reply-To: <1239835980-22502-19-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/pasemi_mac.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 5eeb5a8..067caba 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1735,6 +1735,19 @@ out:
 	return ret;
 }
 
+static const struct net_device_ops pasemi_netdev_ops = {
+	.ndo_open		= pasemi_mac_open,
+	.ndo_stop		= pasemi_mac_close,
+	.ndo_start_xmit		= pasemi_mac_start_tx,
+	.ndo_set_multicast_list	= pasemi_mac_set_rx_mode,
+	.ndo_set_mac_address	= pasemi_mac_set_mac_addr,
+	.ndo_change_mtu		= pasemi_mac_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= pasemi_mac_netpoll,
+#endif
+};
+
 static int __devinit
 pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1817,19 +1830,11 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto out;
 	}
 
-	dev->open = pasemi_mac_open;
-	dev->stop = pasemi_mac_close;
-	dev->hard_start_xmit = pasemi_mac_start_tx;
-	dev->set_multicast_list = pasemi_mac_set_rx_mode;
-	dev->set_mac_address = pasemi_mac_set_mac_addr;
+	dev->netdev_ops = &pasemi_netdev_ops;
 	dev->mtu = PE_DEF_MTU;
 	/* 1500 MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
 	mac->bufsz = dev->mtu + ETH_HLEN + ETH_FCS_LEN + LOCAL_SKB_ALIGN + 128;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = pasemi_mac_netpoll;
-#endif
 
-	dev->change_mtu = pasemi_mac_change_mtu;
 	dev->ethtool_ops = &pasemi_mac_ethtool_ops;
 
 	if (err)
-- 
1.6.2.3

