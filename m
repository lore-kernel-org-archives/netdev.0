From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] use netdev_priv() in fusion/mptlan
Date: Thu, 4 Mar 2004 13:20:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304132037.5c447dde.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


| 
| From: Carlo Perassi <carlo@linux.it>
| and Randy.Dunap <rddunlap@osdl.org>


--
~Randy



 linux-264-302-priv-rddunlap/drivers/message/fusion/mptlan.c |   20 ++++++------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff -puN drivers/message/fusion/mptlan.c~fusion_mptlan_casts drivers/message/fusion/mptlan.c
--- linux-264-302-priv/drivers/message/fusion/mptlan.c~fusion_mptlan_casts	2004-03-02 12:48:15.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/message/fusion/mptlan.c	2004-03-02 12:52:10.000000000 -0800
@@ -337,7 +337,7 @@ static int
 mpt_lan_ioc_reset(MPT_ADAPTER *ioc, int reset_phase)
 {
 	struct net_device *dev = mpt_landev[ioc->id];
-	struct mpt_lan_priv *priv = (struct mpt_lan_priv *) dev->priv;
+	struct mpt_lan_priv *priv = netdev_priv(dev);
 
 	dlprintk((KERN_INFO MYNAM ": IOC %s_reset routed to LAN driver!\n",
 			reset_phase==MPT_IOC_PRE_RESET ? "pre" : "post"));
@@ -406,7 +406,7 @@ mpt_lan_event_process(MPT_ADAPTER *ioc, 
 static int
 mpt_lan_open(struct net_device *dev)
 {
-	struct mpt_lan_priv *priv = (struct mpt_lan_priv *) dev->priv;
+	struct mpt_lan_priv *priv = netdev_priv(dev);
 	int i;
 
 	if (mpt_lan_reset(dev) != 0) {
@@ -497,7 +497,7 @@ mpt_lan_reset(struct net_device *dev)
 {
 	MPT_FRAME_HDR *mf;
 	LANResetRequest_t *pResetReq;
-	struct mpt_lan_priv *priv = (struct mpt_lan_priv *)dev->priv;
+	struct mpt_lan_priv *priv = netdev_priv(dev);
 
 	mf = mpt_get_msg_frame(LanCtx, priv->mpt_dev->id);
 
@@ -526,7 +526,7 @@ mpt_lan_reset(struct net_device *dev)
 static int
 mpt_lan_close(struct net_device *dev)
 {
-	struct mpt_lan_priv *priv = (struct mpt_lan_priv *) dev->priv;
+	struct mpt_lan_priv *priv = netdev_priv(dev);
 	MPT_ADAPTER *mpt_dev = priv->mpt_dev;
 	unsigned int timeout;
 	int i;
@@ -587,7 +587,7 @@ mpt_lan_close(struct net_device *dev)
 static struct net_device_stats *
 mpt_lan_get_stats(struct net_device *dev)
 {
-	struct mpt_lan_priv *priv = (struct mpt_lan_priv *)dev->priv;
+	struct mpt_lan_priv *priv = netdev_priv(dev);
 
 	return (struct net_device_stats *) &priv->stats;
 }
@@ -607,7 +607,7 @@ mpt_lan_change_mtu(struct net_device *de
 static void
 mpt_lan_tx_timeout(struct net_device *dev)
 {
-	struct mpt_lan_priv *priv = (struct mpt_lan_priv *) dev->priv;
+	struct mpt_lan_priv *priv = netdev_priv(dev);
 	MPT_ADAPTER *mpt_dev = priv->mpt_dev;
 
 	if (mpt_dev->active) {
@@ -621,7 +621,7 @@ mpt_lan_tx_timeout(struct net_device *de
 static int
 mpt_lan_send_turbo(struct net_device *dev, u32 tmsg)
 {
-	struct mpt_lan_priv *priv = (struct mpt_lan_priv *) dev->priv;
+	struct mpt_lan_priv *priv = netdev_priv(dev);
 	MPT_ADAPTER *mpt_dev = priv->mpt_dev;
 	struct sk_buff *sent;
 	unsigned long flags;
@@ -654,7 +654,7 @@ mpt_lan_send_turbo(struct net_device *de
 static int
 mpt_lan_send_reply(struct net_device *dev, LANSendReply_t *pSendRep)
 {
-	struct mpt_lan_priv *priv = (struct mpt_lan_priv *) dev->priv;
+	struct mpt_lan_priv *priv = netdev_priv(dev);
 	MPT_ADAPTER *mpt_dev = priv->mpt_dev;
 	struct sk_buff *sent;
 	unsigned long flags;
@@ -727,7 +727,7 @@ out:
 static int
 mpt_lan_sdu_send (struct sk_buff *skb, struct net_device *dev)
 {
-	struct mpt_lan_priv *priv = (struct mpt_lan_priv *) dev->priv;
+	struct mpt_lan_priv *priv = netdev_priv(dev);
 	MPT_ADAPTER *mpt_dev = priv->mpt_dev;
 	MPT_FRAME_HDR *mf;
 	LANSendRequest_t *pSendReq;
@@ -1369,7 +1369,7 @@ mpt_register_lan_device (MPT_ADAPTER *mp
 
 	dev->mtu = MPT_LAN_MTU;
 
-	priv = (struct mpt_lan_priv *) dev->priv;
+	priv = netdev_priv(dev);
 
 	priv->mpt_dev = mpt_dev;
 	priv->pnum = pnum;

_


--
~Randy
