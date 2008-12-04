From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next]simeth: Kill directly reference of netdev->priv
Date: Thu, 04 Dec 2008 20:56:02 +0800
Message-ID: <4937D362.4030500@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56936 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756597AbYLDM4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 07:56:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simply replace netdev->priv with netdev_priv().

Not do compile test, because no ia64 box.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 arch/ia64/hp/sim/simeth.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
index 3d47839..c51b32c 100644
--- a/arch/ia64/hp/sim/simeth.c
+++ b/arch/ia64/hp/sim/simeth.c
@@ -206,7 +206,7 @@ simeth_probe1(void)
 
 	memcpy(dev->dev_addr, mac_addr, sizeof(mac_addr));
 
-	local = dev->priv;
+	local = netdev_priv(dev);
 	local->simfd = fd; /* keep track of underlying file descriptor */
 
 	dev->open		= simeth_open;
@@ -325,7 +325,7 @@ simeth_device_event(struct notifier_block *this,unsigned long event, void *ptr)
 	 * we get DOWN then UP.
 	 */
 
-	local = dev->priv;
+	local = netdev_priv(dev);
 	/* now do it for real */
 	r = event == NETDEV_UP ?
 		netdev_attach(local->simfd, dev->irq, ntohl(ifa->ifa_local)):
@@ -380,7 +380,7 @@ frame_print(unsigned char *from, unsigned char *frame, int len)
 static int
 simeth_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct simeth_local *local = dev->priv;
+	struct simeth_local *local = netdev_priv(dev);
 
 #if 0
 	/* ensure we have at least ETH_ZLEN bytes (min frame size) */
@@ -443,7 +443,7 @@ simeth_rx(struct net_device *dev)
 	int			len;
 	int			rcv_count = SIMETH_RECV_MAX;
 
-	local = dev->priv;
+	local = netdev_priv(dev);
 	/*
 	 * the loop concept has been borrowed from other drivers
 	 * looks to me like it's a throttling thing to avoid pushing to many
@@ -507,7 +507,7 @@ simeth_interrupt(int irq, void *dev_id)
 static struct net_device_stats *
 simeth_get_stats(struct net_device *dev)
 {
-	struct simeth_local *local = dev->priv;
+	struct simeth_local *local = netdev_priv(dev);
 
 	return &local->stats;
 }
-- 
1.5.3.4


