From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH] virtio_net: implements ethtool_ops.get_drvinfo
Date: Fri, 11 Jun 2010 10:29:02 +0900
Message-ID: <4C11915E.6090201@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:47393 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754052Ab0FKB3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 21:29:13 -0400
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5B1TCG6024441
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Fri, 11 Jun 2010 10:29:12 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0246045DE54
	for <netdev@vger.kernel.org>; Fri, 11 Jun 2010 10:29:12 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C657845DE51
	for <netdev@vger.kernel.org>; Fri, 11 Jun 2010 10:29:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E574E08003
	for <netdev@vger.kernel.org>; Fri, 11 Jun 2010 10:29:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 460251DB8016
	for <netdev@vger.kernel.org>; Fri, 11 Jun 2010 10:29:11 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements ethtool_ops.get_drvinfo interface of virtio_net driver.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/virtio_net.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

Index: net-next.35/drivers/net/virtio_net.c
===================================================================
--- net-next.35.orig/drivers/net/virtio_net.c
+++ net-next.35/drivers/net/virtio_net.c
@@ -701,6 +701,18 @@ static int virtnet_close(struct net_devi
 	return 0;
 }

+static void virtnet_get_drvinfo(struct net_device *dev,
+				struct ethtool_drvinfo *drvinfo)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct virtio_device *vdev = vi->vdev;
+
+	strncpy(drvinfo->driver, KBUILD_MODNAME, 32);
+	strncpy(drvinfo->version, "N/A", 32);
+	strncpy(drvinfo->fw_version, "N/A", 32);
+	strncpy(drvinfo->bus_info, dev_name(&vdev->dev), 32);
+}
+
 static int virtnet_set_tx_csum(struct net_device *dev, u32 data)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
@@ -813,6 +825,7 @@ static void virtnet_vlan_rx_kill_vid(str
 }

 static const struct ethtool_ops virtnet_ethtool_ops = {
+	.get_drvinfo = virtnet_get_drvinfo,
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
 	.set_tso = ethtool_op_set_tso,

