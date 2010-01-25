From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next-2.6] virtio_net: Set vlan_features to enable
 offloads on vlan devices
Date: Mon, 25 Jan 2010 13:16:16 -0800
Message-ID: <1264454176.28852.129.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:42178 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734Ab0AYVQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 16:16:34 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0PLASQp005725
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 14:10:28 -0700
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o0PLGRvu256638
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 14:16:28 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0PLIPLd026375
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 14:18:26 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set vlan_features in virtnet_probe() so that all the available offloads
are enabled on vlan devices attached to virtio_net devices.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -872,6 +872,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->features |= NETIF_F_UFO;
 	}
 
+	dev->vlan_features = dev->features;
+
 	/* Configuration may specify what MAC to use.  Otherwise random. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC)) {
 		vdev->config->get(vdev,


