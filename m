From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next]mptlan: Kill directly reference of netdev->priv
Date: Tue, 02 Dec 2008 21:32:37 +0800
Message-ID: <493538F5.3000500@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52242 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754728AbYLBNcq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 08:32:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simply replace netdev->priv with netdev_priv().

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/message/fusion/mptlan.c |   10 +++++-----
 drivers/message/fusion/mptlan.h |    2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/message/fusion/mptlan.c b/drivers/message/fusion/mptlan.c
index eeef0bd..a13f6ee 100644
--- a/drivers/message/fusion/mptlan.c
+++ b/drivers/message/fusion/mptlan.c
@@ -815,7 +815,7 @@ mpt_lan_wake_post_buckets_task(struct net_device *dev, int priority)
  * @priority: 0 = put it on the timer queue, 1 = put it on the immediate queue
  */
 {
-	struct mpt_lan_priv *priv = dev->priv;
+	struct mpt_lan_priv *priv = netdev_priv(dev);
 	
 	if (test_and_set_bit(0, &priv->post_buckets_active) == 0) {
 		if (priority) {
@@ -834,7 +834,7 @@ mpt_lan_wake_post_buckets_task(struct net_device *dev, int priority)
 static int
 mpt_lan_receive_skb(struct net_device *dev, struct sk_buff *skb)
 {
-	struct mpt_lan_priv *priv = dev->priv;
+	struct mpt_lan_priv *priv = netdev_priv(dev);
 
 	skb->protocol = mpt_lan_type_trans(skb, dev);
 
@@ -866,7 +866,7 @@ mpt_lan_receive_skb(struct net_device *dev, struct sk_buff *skb)
 static int
 mpt_lan_receive_post_turbo(struct net_device *dev, u32 tmsg)
 {
-	struct mpt_lan_priv *priv = dev->priv;
+	struct mpt_lan_priv *priv = netdev_priv(dev);
 	MPT_ADAPTER *mpt_dev = priv->mpt_dev;
 	struct sk_buff *skb, *old_skb;
 	unsigned long flags;
@@ -921,7 +921,7 @@ static int
 mpt_lan_receive_post_free(struct net_device *dev,
 			  LANReceivePostReply_t *pRecvRep)
 {
-	struct mpt_lan_priv *priv = dev->priv;
+	struct mpt_lan_priv *priv = netdev_priv(dev);
 	MPT_ADAPTER *mpt_dev = priv->mpt_dev;
 	unsigned long flags;
 	struct sk_buff *skb;
@@ -976,7 +976,7 @@ static int
 mpt_lan_receive_post_reply(struct net_device *dev,
 			   LANReceivePostReply_t *pRecvRep)
 {
-	struct mpt_lan_priv *priv = dev->priv;
+	struct mpt_lan_priv *priv = netdev_priv(dev);
 	MPT_ADAPTER *mpt_dev = priv->mpt_dev;
 	struct sk_buff *skb, *old_skb;
 	unsigned long flags;
diff --git a/drivers/message/fusion/mptlan.h b/drivers/message/fusion/mptlan.h
index 33927ee..c171afa 100644
--- a/drivers/message/fusion/mptlan.h
+++ b/drivers/message/fusion/mptlan.h
@@ -122,7 +122,7 @@ MODULE_DESCRIPTION(LANAME);
 #define dlprintk(x)
 #endif
 
-#define NETDEV_TO_LANPRIV_PTR(d)	((struct mpt_lan_priv *)(d)->priv)
+#define NETDEV_TO_LANPRIV_PTR(d)	((struct mpt_lan_priv *)netdev_priv(d))
 #define NETDEV_PTR_TO_IOC_NAME_s(d)	(NETDEV_TO_LANPRIV_PTR(d)->mpt_dev->name)
 #define IOC_AND_NETDEV_NAMES_s_s(d)	NETDEV_PTR_TO_IOC_NAME_s(d), (d)->name
 
-- 
1.5.3.4


