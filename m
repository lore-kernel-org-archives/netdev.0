From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net_sched: cls_flow: add key rxhash
Date: Sun, 22 Aug 2010 00:23:15 +0800
Message-ID: <1282407795-3449-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:42235 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373Ab0HUQXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Aug 2010 12:23:40 -0400
Received: by pvg2 with SMTP id 2so1662758pvg.19
        for <netdev@vger.kernel.org>; Sat, 21 Aug 2010 09:23:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can use rxhash to classify the traffic into flows. As rxhash maybe
supplied by NIC or RPS, it is cheaper.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/linux/pkt_cls.h |    1 +
 net/sched/cls_flow.c    |    7 +++++++
 2 files changed, 8 insertions(+)
diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 7f6ba86..defbde2 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -332,6 +332,7 @@ enum {
 	FLOW_KEY_SKUID,
 	FLOW_KEY_SKGID,
 	FLOW_KEY_VLAN_TAG,
+	FLOW_KEY_RXHASH,
 	__FLOW_KEY_MAX,
 };
 
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index cd709f1..5b271a1 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -306,6 +306,11 @@ static u32 flow_get_vlan_tag(const struct sk_buff *skb)
 	return tag & VLAN_VID_MASK;
 }
 
+static u32 flow_get_rxhash(struct sk_buff *skb)
+{
+	return skb_get_rxhash(skb);
+}
+
 static u32 flow_key_get(struct sk_buff *skb, int key)
 {
 	switch (key) {
@@ -343,6 +348,8 @@ static u32 flow_key_get(struct sk_buff *skb, int key)
 		return flow_get_skgid(skb);
 	case FLOW_KEY_VLAN_TAG:
 		return flow_get_vlan_tag(skb);
+	case FLOW_KEY_RXHASH:
+		return flow_get_rxhash(skb);
 	default:
 		WARN_ON(1);
 		return 0;
