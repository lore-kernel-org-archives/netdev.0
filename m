From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 22/26] rionet: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:56 +0400
Message-ID: <1239835980-22502-22-git-send-email-a.beregalov@gmail.com>
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
 <1239835980-22502-21-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:38634 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756630AbZDOWxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:30 -0400
Received: by mail-bw0-f169.google.com with SMTP id 17so114630bwz.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:30 -0700 (PDT)
In-Reply-To: <1239835980-22502-21-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/rionet.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index ec59e29..8702e7a 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -428,6 +428,15 @@ static const struct ethtool_ops rionet_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 };
 
+static const struct net_device_ops rionet_netdev_ops = {
+	.ndo_open		= rionet_open,
+	.ndo_stop		= rionet_close,
+	.ndo_start_xmit		= rionet_start_xmit,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int rionet_setup_netdev(struct rio_mport *mport)
 {
 	int rc = 0;
@@ -466,10 +475,7 @@ static int rionet_setup_netdev(struct rio_mport *mport)
 	ndev->dev_addr[4] = device_id >> 8;
 	ndev->dev_addr[5] = device_id & 0xff;
 
-	/* Fill in the driver function table */
-	ndev->open = &rionet_open;
-	ndev->hard_start_xmit = &rionet_start_xmit;
-	ndev->stop = &rionet_close;
+	ndev->netdev_ops = &rionet_netdev_ops;
 	ndev->mtu = RIO_MAX_MSG_SIZE - 14;
 	ndev->features = NETIF_F_LLTX;
 	SET_ETHTOOL_OPS(ndev, &rionet_ethtool_ops);
-- 
1.6.2.3

