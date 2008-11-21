From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next 1/2] netdevice pc300: Convert directly reference
 of netdev->priv
Date: Fri, 21 Nov 2008 17:02:54 +0800
Message-ID: <4926793E.3080208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65269 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752482AbYKUJDJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 04:03:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev's private data should be hdlc.
pc300dev_t is the private data of hdlc.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/wan/pc300_drv.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index d0a8d1e..d67957a 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -1769,7 +1769,7 @@ cpc_trace(struct net_device *dev, struct sk_buff *skb_main, char rx_tx)
 
 static void cpc_tx_timeout(struct net_device *dev)
 {
-	pc300dev_t *d = (pc300dev_t *) dev->priv;
+	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
 	int ch = chan->channel;
@@ -1796,7 +1796,7 @@ static void cpc_tx_timeout(struct net_device *dev)
 
 static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	pc300dev_t *d = (pc300dev_t *) dev->priv;
+	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
 	int ch = chan->channel;
@@ -1874,7 +1874,7 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static void cpc_net_rx(struct net_device *dev)
 {
-	pc300dev_t *d = (pc300dev_t *) dev->priv;
+	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
 	int ch = chan->channel;
@@ -2522,7 +2522,7 @@ static int cpc_change_mtu(struct net_device *dev, int new_mtu)
 
 static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	pc300dev_t *d = (pc300dev_t *) dev->priv;
+	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
 	pc300conf_t conf_aux;
@@ -3058,7 +3058,7 @@ static int tx_config(pc300dev_t * d)
 static int cpc_attach(struct net_device *dev, unsigned short encoding,
 		      unsigned short parity)
 {
-	pc300dev_t *d = (pc300dev_t *)dev->priv;
+	pc300dev_t *d = (pc300dev_t *)dev_to_hdlc(dev)->priv;
 	pc300ch_t *chan = (pc300ch_t *)d->chan;
 	pc300_t *card = (pc300_t *)chan->card;
 	pc300chconf_t *conf = (pc300chconf_t *)&chan->conf;
@@ -3138,7 +3138,7 @@ static void cpc_closech(pc300dev_t * d)
 
 int cpc_open(struct net_device *dev)
 {
-	pc300dev_t *d = (pc300dev_t *) dev->priv;
+	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
 	struct ifreq ifr;
 	int result;
 
@@ -3166,7 +3166,7 @@ err_out:
 
 static int cpc_close(struct net_device *dev)
 {
-	pc300dev_t *d = (pc300dev_t *) dev->priv;
+	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
 	unsigned long flags;
@@ -3347,7 +3347,7 @@ static void cpc_init_card(pc300_t * card)
 		d->line_on = 0;
 		d->line_off = 0;
 
-		dev = alloc_hdlcdev(NULL);
+		dev = alloc_hdlcdev(d);
 		if (dev == NULL)
 			continue;
 
@@ -3372,7 +3372,6 @@ static void cpc_init_card(pc300_t * card)
 		dev->do_ioctl = cpc_ioctl;
 
 		if (register_hdlc_device(dev) == 0) {
-			dev->priv = d;	/* We need 'priv', hdlc doesn't */
 			printk("%s: Cyclades-PC300/", dev->name);
 			switch (card->hw.type) {
 				case PC300_TE:
-- 
1.5.3.4



