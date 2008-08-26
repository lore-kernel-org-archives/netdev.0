From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 8/15] netdevice cycx_x25: Convert directly reference of netdev->priv
 to netdev_priv()
Date: Tue, 26 Aug 2008 18:25:05 +0800
Message-ID: <48B3DA01.2010602@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63954 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752985AbYHZK1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 06:27:31 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/wan/cycx_x25.c |   42 +++++++++++++++++++++---------------------
 1 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
index d3b28b0..5309220 100644
--- a/drivers/net/wan/cycx_x25.c
+++ b/drivers/net/wan/cycx_x25.c
@@ -445,7 +445,7 @@ static int cycx_wan_new_if(struct wan_device *wandev, struct net_device *dev,
 	/* prepare network device data space for registration */
 	strcpy(dev->name, chan->name);
 	dev->init = cycx_netdevice_init;
-	dev->priv = chan;
+	dev->ml_priv = chan;
 
 	return 0;
 }
@@ -453,8 +453,8 @@ static int cycx_wan_new_if(struct wan_device *wandev, struct net_device *dev,
 /* Delete logical channel. */
 static int cycx_wan_del_if(struct wan_device *wandev, struct net_device *dev)
 {
-	if (dev->priv) {
-		struct cycx_x25_channel *chan = dev->priv;
+	if (dev->ml_priv) {
+		struct cycx_x25_channel *chan = dev->ml_priv;
 
 		if (chan->svc) {
 			kfree(chan->local_addr);
@@ -463,7 +463,7 @@ static int cycx_wan_del_if(struct wan_device *wandev, struct net_device *dev)
 		}
 
 		kfree(chan);
-		dev->priv = NULL;
+		dev->ml_priv = NULL;
 	}
 
 	return 0;
@@ -484,7 +484,7 @@ static const struct header_ops cycx_header_ops = {
  * registration. */
 static int cycx_netdevice_init(struct net_device *dev)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = dev->ml_priv;
 	struct cycx_device *card = chan->card;
 	struct wan_device *wandev = &card->wandev;
 
@@ -542,7 +542,7 @@ static int cycx_netdevice_open(struct net_device *dev)
  * o if there's no more open channels then disconnect physical link. */
 static int cycx_netdevice_stop(struct net_device *dev)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = dev->ml_priv;
 
 	netif_stop_queue(dev);
 
@@ -596,7 +596,7 @@ static int cycx_netdevice_rebuild_header(struct sk_buff *skb)
 static int cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
 					  struct net_device *dev)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = dev->ml_priv;
 	struct cycx_device *card = chan->card;
 
 	if (!chan->svc)
@@ -670,7 +670,7 @@ free_packet:
  * Return a pointer to struct net_device_stats */
 static struct net_device_stats *cycx_netdevice_get_stats(struct net_device *dev)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = dev->ml_priv;
 
 	return chan ? &chan->ifstats : NULL;
 }
@@ -783,7 +783,7 @@ static void cycx_x25_irq_rx(struct cycx_device *card, struct cycx_x25_cmd *cmd)
 		return;
 	}
 
-	chan = dev->priv;
+	chan = dev->ml_priv;
 	reset_timer(dev);
 
 	if (chan->drop_sequence) {
@@ -884,7 +884,7 @@ static void cycx_x25_irq_connect(struct cycx_device *card,
 		return;
 	}
 
-	chan = dev->priv;
+	chan = dev->ml_priv;
 	chan->lcn = lcn;
 	cycx_x25_connect_response(card, chan);
 	cycx_x25_set_chan_state(dev, WAN_CONNECTED);
@@ -914,7 +914,7 @@ static void cycx_x25_irq_connect_confirm(struct cycx_device *card,
 	}
 
 	clear_bit(--key, (void*)&card->u.x.connection_keys);
-	chan = dev->priv;
+	chan = dev->ml_priv;
 	chan->lcn = lcn;
 	cycx_x25_set_chan_state(dev, WAN_CONNECTED);
 }
@@ -954,7 +954,7 @@ static void cycx_x25_irq_disconnect(struct cycx_device *card,
 
 	dev = cycx_x25_get_dev_by_lcn(wandev, lcn);
 	if (dev) {
-		struct cycx_x25_channel *chan = dev->priv;
+		struct cycx_x25_channel *chan = dev->ml_priv;
 
 		cycx_x25_disconnect_response(card, chan->link, lcn);
 		cycx_x25_set_chan_state(dev, WAN_DISCONNECTED);
@@ -1302,7 +1302,7 @@ static struct net_device *cycx_x25_get_dev_by_lcn(struct wan_device *wandev,
 	struct cycx_x25_channel *chan;
 
 	while (dev) {
-		chan = (struct cycx_x25_channel*)dev->priv;
+		chan = (struct cycx_x25_channel *)dev->ml_priv;
 
 		if (chan->lcn == lcn)
 			break;
@@ -1319,7 +1319,7 @@ static struct net_device *
 	struct cycx_x25_channel *chan;
 
 	while (dev) {
-		chan = (struct cycx_x25_channel*)dev->priv;
+		chan = (struct cycx_x25_channel *)dev->ml_priv;
 
 		if (!strcmp(chan->addr, dte))
 			break;
@@ -1337,7 +1337,7 @@ static struct net_device *
  *		<0	failure */
 static int cycx_x25_chan_connect(struct net_device *dev)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = dev->ml_priv;
 	struct cycx_device *card = chan->card;
 
 	if (chan->svc) {
@@ -1362,7 +1362,7 @@ static int cycx_x25_chan_connect(struct net_device *dev)
  * o if SVC then clear X.25 call */
 static void cycx_x25_chan_disconnect(struct net_device *dev)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = dev->ml_priv;
 
 	if (chan->svc) {
 		x25_clear_call(chan->card, chan->link, chan->lcn, 0, 0);
@@ -1375,7 +1375,7 @@ static void cycx_x25_chan_disconnect(struct net_device *dev)
 static void cycx_x25_chan_timer(unsigned long d)
 {
 	struct net_device *dev = (struct net_device *)d;
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = dev->ml_priv;
 
 	if (chan->state == WAN_CONNECTED)
 		cycx_x25_chan_disconnect(dev);
@@ -1387,7 +1387,7 @@ static void cycx_x25_chan_timer(unsigned long d)
 /* Set logical channel state. */
 static void cycx_x25_set_chan_state(struct net_device *dev, u8 state)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = dev->ml_priv;
 	struct cycx_device *card = chan->card;
 	unsigned long flags;
 	char *string_state = NULL;
@@ -1453,7 +1453,7 @@ static void cycx_x25_set_chan_state(struct net_device *dev, u8 state)
  *    to the router.  */
 static int cycx_x25_chan_send(struct net_device *dev, struct sk_buff *skb)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = dev->ml_priv;
 	struct cycx_device *card = chan->card;
 	int bitm = 0;		/* final packet */
 	unsigned len = skb->len;
@@ -1547,7 +1547,7 @@ static unsigned dec_to_uint(u8 *str, int len)
 
 static void reset_timer(struct net_device *dev)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = dev->ml_priv;
 
 	if (chan->svc)
 		mod_timer(&chan->timer, jiffies+chan->idle_tmout*HZ);
@@ -1600,7 +1600,7 @@ static void cycx_x25_dump_devs(struct wan_device *wandev)
 	printk(KERN_INFO "---------------------------------------\n");
 
 	while(dev) {
-		struct cycx_x25_channel *chan = dev->priv;
+		struct cycx_x25_channel *chan = dev->ml_priv;
 
 		printk(KERN_INFO "%-5.5s %-15.15s   %d     ETH_P_%s\n",
 				 chan->name, chan->addr, netif_queue_stopped(dev),
-- 
1.5.3.4


