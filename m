From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH 3/3] veth: don't assign a qdisc to veth
Date: Wed, 29 Jul 2015 22:51:43 +0200
Message-ID: <1438203103-27013-4-git-send-email-phil@nwl.cc>
References: <1438203103-27013-1-git-send-email-phil@nwl.cc>
 <1438203103-27013-2-git-send-email-phil@nwl.cc>
 <1438203103-27013-3-git-send-email-phil@nwl.cc>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Cong Wang <cwang@twopensource.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:53151 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753819AbbG2Uvr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 16:51:47 -0400
In-Reply-To: <1438203103-27013-3-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>

The veth driver is a virtual device, and should not have assigned
the default qdisc.  Verified (ndo_start_xmit) veth_xmit can only
return NETDEV_TX_OK, thus this should be safe to bypass qdisc.

Not assigning a qdisc is subtly done by setting tx_queue_len to zero.

Reported-by: Mrunal Patel <mpatel@redhat.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 drivers/net/veth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index c8186ff..6b3d822 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -302,6 +302,7 @@ static const struct net_device_ops veth_netdev_ops = {
 static void veth_setup(struct net_device *dev)
 {
 	ether_setup(dev);
+	dev->tx_queue_len = 0;
 
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
-- 
2.1.2
