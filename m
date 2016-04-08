From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] tuntap: restore default qdisc
Date: Fri,  8 Apr 2016 13:26:48 +0800
Message-ID: <1460093208-4364-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>,
	Phil Sutter <phil@nwl.cc>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55973 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750758AbcDHF0y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2016 01:26:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit f84bb1eac027 ("net: fix IFF_NO_QUEUE for drivers using
alloc_netdev"), default qdisc was changed to noqueue because
tuntap does not set tx_queue_len during .setup(). This patch restores
default qdisc by setting tx_queue_len in tun_setup().

Fixes: f84bb1eac027 ("net: fix IFF_NO_QUEUE for drivers using alloc_netdev")
Cc: Phil Sutter <phil@nwl.cc>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 510e90a..2c9e45f5 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1015,7 +1015,6 @@ static void tun_net_init(struct net_device *dev)
 		/* Zero header length */
 		dev->type = ARPHRD_NONE;
 		dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
-		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
 		break;
 
 	case IFF_TAP:
@@ -1027,7 +1026,6 @@ static void tun_net_init(struct net_device *dev)
 
 		eth_hw_addr_random(dev);
 
-		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
 		break;
 	}
 }
@@ -1481,6 +1479,8 @@ static void tun_setup(struct net_device *dev)
 
 	dev->ethtool_ops = &tun_ethtool_ops;
 	dev->destructor = tun_free_netdev;
+	/* We prefer our own queue length */
+	dev->tx_queue_len = TUN_READQ_SIZE;
 }
 
 /* Trivial set of netlink ops to allow deleting tun or tap
-- 
2.5.0
