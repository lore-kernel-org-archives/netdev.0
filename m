From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH] veth: don't assign a qdisc to veth
Date: Fri, 03 Oct 2014 12:48:58 +0200
Message-ID: <20141003104858.6745.62964.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, mpatel@redhat.com
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3818 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282AbaJCKtA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 06:49:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The veth driver is a virtual device, and should not have assigned
the default qdisc.  Verified (ndo_start_xmit) veth_xmit can only
return NETDEV_TX_OK, thus this should be safe to bypass qdisc.

Not assigning a qdisc is subtly done by setting tx_queue_len to zero.

Reported-by: Mrunal Patel <mpatel@redhat.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 drivers/net/veth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 8ad5965..3c32fcf 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -287,6 +287,7 @@ static const struct net_device_ops veth_netdev_ops = {
 static void veth_setup(struct net_device *dev)
 {
 	ether_setup(dev);
+	dev->tx_queue_len = 0;
 
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
