From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 09/26] iseries_veth: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:43 +0400
Message-ID: <1239835980-22502-9-git-send-email-a.beregalov@gmail.com>
References: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-3-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-4-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-5-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-6-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-7-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-8-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.190]:46138 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754219AbZDOWxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:16 -0400
Received: by mu-out-0910.google.com with SMTP id g7so51288muf.1
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:14 -0700 (PDT)
In-Reply-To: <1239835980-22502-8-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/iseries_veth.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index cb793c2..264654d 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -1021,6 +1021,16 @@ static const struct ethtool_ops ops = {
 	.get_link = veth_get_link,
 };
 
+static const struct net_device_ops veth_netdev_ops = {
+	.ndo_open		= veth_open,
+	.ndo_stop		= veth_close,
+	.ndo_start_xmit		= veth_start_xmit,
+	.ndo_change_mtu		= veth_change_mtu,
+	.ndo_set_multicast_list	= veth_set_multicast_list,
+	.ndo_set_mac_address	= NULL,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static struct net_device *veth_probe_one(int vlan,
 		struct vio_dev *vio_dev)
 {
@@ -1067,12 +1077,7 @@ static struct net_device *veth_probe_one(int vlan,
 
 	memcpy(&port->mac_addr, mac_addr, ETH_ALEN);
 
-	dev->open = veth_open;
-	dev->hard_start_xmit = veth_start_xmit;
-	dev->stop = veth_close;
-	dev->change_mtu = veth_change_mtu;
-	dev->set_mac_address = NULL;
-	dev->set_multicast_list = veth_set_multicast_list;
+	dev->netdev = &veth_netdev_ops;
 	SET_ETHTOOL_OPS(dev, &ops);
 
 	SET_NETDEV_DEV(dev, vdev);
-- 
1.6.2.3

