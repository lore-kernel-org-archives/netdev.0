From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next] sgi-xp: Kill directly reference of netdev->priv
Date: Thu, 04 Dec 2008 20:56:47 +0800
Message-ID: <4937D38F.6010102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58155 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753737AbYLDM4x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 07:56:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simply replace netdev->priv with netdev_priv().

Not do compile test, because no IA64 or x86_64 box.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/misc/sgi-xp/xpnet.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/misc/sgi-xp/xpnet.c b/drivers/misc/sgi-xp/xpnet.c
index 71513b3..9e5233a 100644
--- a/drivers/misc/sgi-xp/xpnet.c
+++ b/drivers/misc/sgi-xp/xpnet.c
@@ -154,7 +154,7 @@ xpnet_receive(short partid, int channel, struct xpnet_message *msg)
 	void *dst;
 	enum xp_retval ret;
 	struct xpnet_dev_private *priv =
-	    (struct xpnet_dev_private *)xpnet_device->priv;
+	    (struct xpnet_dev_private *)netdev_priv(xpnet_device);
 
 	if (!XPNET_VALID_MSG(msg)) {
 		/*
@@ -370,7 +370,7 @@ xpnet_dev_get_stats(struct net_device *dev)
 {
 	struct xpnet_dev_private *priv;
 
-	priv = (struct xpnet_dev_private *)dev->priv;
+	priv = (struct xpnet_dev_private *)netdev_priv(dev);
 
 	return &priv->stats;
 }
@@ -456,7 +456,8 @@ xpnet_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct xpnet_pending_msg *queued_msg;
 	u64 start_addr, end_addr;
 	short dest_partid;
-	struct xpnet_dev_private *priv = (struct xpnet_dev_private *)dev->priv;
+	struct xpnet_dev_private *priv =
+		(struct xpnet_dev_private *)netdev_priv(dev);
 	u16 embedded_bytes = 0;
 
 	dev_dbg(xpnet, ">skb->head=0x%p skb->data=0x%p skb->tail=0x%p "
@@ -543,7 +544,7 @@ xpnet_dev_tx_timeout(struct net_device *dev)
 {
 	struct xpnet_dev_private *priv;
 
-	priv = (struct xpnet_dev_private *)dev->priv;
+	priv = (struct xpnet_dev_private *)netdev_priv(dev);
 
 	priv->stats.tx_errors++;
 	return;
-- 
1.5.3.4


