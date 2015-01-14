From: David Ahern <dsahern@gmail.com>
Subject: [PATCH] net: rocker: Add basic netdev counters
Date: Wed, 14 Jan 2015 15:39:21 -0700
Message-ID: <1421275161-99434-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>, Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:47663 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbbANWjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 17:39:25 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so13366110pad.1
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 14:39:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add packet and byte counters for RX and TX paths.

$ ifconfig eth1
eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet6 fe80::5054:ff:fe12:3501  prefixlen 64  scopeid 0x20<link>
        ether 52:54:00:12:35:01  txqueuelen 1000  (Ethernet)
        RX packets 63  bytes 15813 (15.4 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 79  bytes 17991 (17.5 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

Signed-off-by: David Ahern <dsahern@gmail.com>
Cc: Scott Feldman <sfeldma@gmail.com>
Cc: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 2f398fa4b9e6..9743279d9121 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3557,6 +3557,9 @@ static netdev_tx_t rocker_port_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!desc_info)
 		netif_stop_queue(dev);
 
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+
 	return NETDEV_TX_OK;
 
 unmap_frags:
@@ -3565,6 +3568,8 @@ static netdev_tx_t rocker_port_xmit(struct sk_buff *skb, struct net_device *dev)
 	rocker_tlv_nest_cancel(desc_info, frags);
 out:
 	dev_kfree_skb(skb);
+	dev->stats.tx_dropped++;
+
 	return NETDEV_TX_OK;
 }
 
@@ -3890,6 +3895,9 @@ static int rocker_port_rx_proc(struct rocker *rocker,
 	skb->protocol = eth_type_trans(skb, rocker_port->dev);
 	netif_receive_skb(skb);
 
+	rocker_port->dev->stats.rx_packets++;
+	rocker_port->dev->stats.rx_bytes += skb->len;
+
 	return rocker_dma_rx_ring_skb_alloc(rocker, rocker_port, desc_info);
 }
 
-- 
1.9.3 (Apple Git-50)
