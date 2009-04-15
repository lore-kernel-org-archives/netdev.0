From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 15/26] macmace: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:49 +0400
Message-ID: <1239835980-22502-15-git-send-email-a.beregalov@gmail.com>
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
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:50591 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755980AbZDOWxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:22 -0400
Received: by mail-bw0-f169.google.com with SMTP id 17so114640bwz.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:22 -0700 (PDT)
In-Reply-To: <1239835980-22502-14-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/macmace.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macmace.c b/drivers/net/macmace.c
index 274e99b..44f3c28 100644
--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -180,6 +180,17 @@ static void mace_dma_off(struct net_device *dev)
 	psc_write_word(PSC_ENETWR_CMD + PSC_SET1, 0x1100);
 }
 
+static const struct net_device_ops mace_netdev_ops = {
+	.ndo_open		= mace_open,
+	.ndo_stop		= mace_close,
+	.ndo_start_xmit		= mace_xmit_start,
+	.ndo_tx_timeout		= mace_tx_timeout,
+	.ndo_set_multicast_list	= mace_set_multicast,
+	.ndo_set_mac_address	= mace_set_address,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /*
  * Not really much of a probe. The hardware table tells us if this
  * model of Macintrash has a MACE (AV macintoshes)
@@ -240,13 +251,8 @@ static int __devinit mace_probe(struct platform_device *pdev)
 		return -ENODEV;
 	}
 
-	dev->open		= mace_open;
-	dev->stop		= mace_close;
-	dev->hard_start_xmit	= mace_xmit_start;
-	dev->tx_timeout		= mace_tx_timeout;
+	dev->netdev_ops		= &mace_netdev_ops;
 	dev->watchdog_timeo	= TX_TIMEOUT;
-	dev->set_multicast_list	= mace_set_multicast;
-	dev->set_mac_address	= mace_set_address;
 
 	printk(KERN_INFO "%s: 68K MACE, hardware address %pM\n",
 	       dev->name, dev->dev_addr);
-- 
1.6.2.3

