From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 14/26] mace: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:48 +0400
Message-ID: <1239835980-22502-14-git-send-email-a.beregalov@gmail.com>
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
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:58032 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755966AbZDOWxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:22 -0400
Received: by fxm2 with SMTP id 2so121450fxm.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:20 -0700 (PDT)
In-Reply-To: <1239835980-22502-13-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/mace.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index feebbd9..1ad740b 100644
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -94,6 +94,16 @@ static void __mace_set_address(struct net_device *dev, void *addr);
  */
 static unsigned char *dummy_buf;
 
+static const struct net_device_ops mace_netdev_ops = {
+	.ndo_open		= mace_open,
+	.ndo_stop		= mace_close,
+	.ndo_start_xmit		= mace_xmit_start,
+	.ndo_set_multicast_list	= mace_set_multicast,
+	.ndo_set_mac_address	= mace_set_address,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __devinit mace_probe(struct macio_dev *mdev, const struct of_device_id *match)
 {
 	struct device_node *mace = macio_get_of_node(mdev);
@@ -207,11 +217,7 @@ static int __devinit mace_probe(struct macio_dev *mdev, const struct of_device_i
 		}
 	}
 
-	dev->open = mace_open;
-	dev->stop = mace_close;
-	dev->hard_start_xmit = mace_xmit_start;
-	dev->set_multicast_list = mace_set_multicast;
-	dev->set_mac_address = mace_set_address;
+	dev->netdev_ops = &mace_netdev_ops;
 
 	/*
 	 * Most of what is below could be moved to mace_open()
-- 
1.6.2.3

