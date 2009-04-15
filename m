From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 01/26] bmac: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:35 +0400
Message-ID: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:48714 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689AbZDOWxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:05 -0400
Received: by fxm2 with SMTP id 2so121386fxm.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/bmac.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index 44d015f..9578a3d 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -1247,6 +1247,16 @@ static const struct ethtool_ops bmac_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
 };
 
+static const struct net_device_ops bmac_netdev_ops = {
+	.ndo_open		= bmac_open,
+	.ndo_stop		= bmac_close,
+	.ndo_start_xmit		= bmac_output,
+	.ndo_set_multicast_list	= bmac_set_multicast,
+	.ndo_set_mac_address	= bmac_set_address,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __devinit bmac_probe(struct macio_dev *mdev, const struct of_device_id *match)
 {
 	int j, rev, ret;
@@ -1308,12 +1318,8 @@ static int __devinit bmac_probe(struct macio_dev *mdev, const struct of_device_i
 	bmac_enable_and_reset_chip(dev);
 	bmwrite(dev, INTDISABLE, DisableAll);
 
-	dev->open = bmac_open;
-	dev->stop = bmac_close;
+	dev->netdev_ops = &bmac_netdev_ops;
 	dev->ethtool_ops = &bmac_ethtool_ops;
-	dev->hard_start_xmit = bmac_output;
-	dev->set_multicast_list = bmac_set_multicast;
-	dev->set_mac_address = bmac_set_address;
 
 	bmac_get_station_address(dev, addr);
 	if (bmac_verify_checksum(dev) != 0)
-- 
1.6.2.3

