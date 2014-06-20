From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] veth: add netpoll support
Date: Fri, 20 Jun 2014 12:17:58 -0700
Message-ID: <1403291878-4199-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: s.priebe@profihost.ag, "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:64201 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbaFTTSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 15:18:09 -0400
Received: by mail-pb0-f45.google.com with SMTP id rr13so3426880pbb.18
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 12:18:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is trivial to add netpoll support to veth, since
it is not stacked device, we don't need to setup and cleanup
netpoll.

Reported-by: Stefan Priebe <s.priebe@profihost.ag>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index b4a10bc..03e781b 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -248,6 +248,13 @@ static void veth_dev_free(struct net_device *dev)
 	free_netdev(dev);
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void veth_poll_controller(struct net_device *dev)
+{
+	return;
+}
+#endif	/* CONFIG_NET_POLL_CONTROLLER */
+
 static const struct net_device_ops veth_netdev_ops = {
 	.ndo_init            = veth_dev_init,
 	.ndo_open            = veth_open,
@@ -257,6 +264,9 @@ static const struct net_device_ops veth_netdev_ops = {
 	.ndo_get_stats64     = veth_get_stats64,
 	.ndo_set_rx_mode     = veth_set_multicast_list,
 	.ndo_set_mac_address = eth_mac_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= veth_poll_controller,
+#endif
 };
 
 #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |    \
