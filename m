From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/6] net: rename bond_queue_mapping to slave_dev_queue_mapping
Date: Fri, 20 Jul 2012 14:28:49 +0200
Message-ID: <1342787331-1866-5-git-send-email-jiri@resnulli.us>
References: <1342787331-1866-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, shemminger@vyatta.com,
	fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:39376 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211Ab2GTM3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 08:29:07 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so3588259wgb.1
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 05:29:07 -0700 (PDT)
In-Reply-To: <1342787331-1866-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As this is going to be used not only by bonding.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c |    6 +++---
 include/net/sch_generic.h       |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f41ddc2..6fae5f3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -395,8 +395,8 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 	skb->dev = slave_dev;
 
 	BUILD_BUG_ON(sizeof(skb->queue_mapping) !=
-		     sizeof(qdisc_skb_cb(skb)->bond_queue_mapping));
-	skb->queue_mapping = qdisc_skb_cb(skb)->bond_queue_mapping;
+		     sizeof(qdisc_skb_cb(skb)->slave_dev_queue_mapping));
+	skb->queue_mapping = qdisc_skb_cb(skb)->slave_dev_queue_mapping;
 
 	if (unlikely(netpoll_tx_running(slave_dev)))
 		bond_netpoll_send_skb(bond_get_slave_by_dev(bond, slave_dev), skb);
@@ -4184,7 +4184,7 @@ static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
 	/*
 	 * Save the original txq to restore before passing to the driver
 	 */
-	qdisc_skb_cb(skb)->bond_queue_mapping = skb->queue_mapping;
+	qdisc_skb_cb(skb)->slave_dev_queue_mapping = skb->queue_mapping;
 
 	if (unlikely(txq >= dev->real_num_tx_queues)) {
 		do {
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 9d7d54a..d9611e0 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -220,7 +220,7 @@ struct tcf_proto {
 
 struct qdisc_skb_cb {
 	unsigned int		pkt_len;
-	u16			bond_queue_mapping;
+	u16			slave_dev_queue_mapping;
 	u16			_pad;
 	unsigned char		data[20];
 };
-- 
1.7.10.4
