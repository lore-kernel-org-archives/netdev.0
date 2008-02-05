From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 04/04]: cls_flow: support classification based on VLAN tag
Date: Tue,  5 Feb 2008 15:29:44 +0100 (MET)
Message-ID: <20080205142907.13543.75941.sendpatchset@localhost.localdomain>
References: <20080205142902.13543.88604.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59227 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476AbYBEO3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 09:29:45 -0500
In-Reply-To: <20080205142902.13543.88604.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: cls_flow: support classification based on VLAN tag

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 104092e6d90cba5fa00902a3154155872d693f42
tree 0e3fd5871a861fa022bbc2f34d314bb8672b556a
parent 03faf81b8195be455c3c7592d76d712ea9d80b13
author Patrick McHardy <kaber@trash.net> Tue, 05 Feb 2008 15:22:23 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 05 Feb 2008 15:22:23 +0100

 include/linux/pkt_cls.h |    1 +
 net/sched/cls_flow.c    |   12 ++++++++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 40fac8c..28dfc61 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -348,6 +348,7 @@ enum
 	FLOW_KEY_RTCLASSID,
 	FLOW_KEY_SKUID,
 	FLOW_KEY_SKGID,
+	FLOW_KEY_VLAN_TAG,
 	__FLOW_KEY_MAX,
 };
 
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index eeb223c..971b867 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -19,6 +19,7 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
+#include <linux/if_vlan.h>
 
 #include <net/pkt_cls.h>
 #include <net/ip.h>
@@ -270,6 +271,15 @@ static u32 flow_get_skgid(const struct sk_buff *skb)
 	return 0;
 }
 
+static u32 flow_get_vlan_tag(const struct sk_buff *skb)
+{
+	u16 uninitialized_var(tag);
+
+	if (vlan_get_tag(skb, &tag) < 0)
+		return 0;
+	return tag & VLAN_VID_MASK;
+}
+
 static u32 flow_key_get(const struct sk_buff *skb, int key)
 {
 	switch (key) {
@@ -305,6 +315,8 @@ static u32 flow_key_get(const struct sk_buff *skb, int key)
 		return flow_get_skuid(skb);
 	case FLOW_KEY_SKGID:
 		return flow_get_skgid(skb);
+	case FLOW_KEY_VLAN_TAG:
+		return flow_get_vlan_tag(skb);
 	default:
 		WARN_ON(1);
 		return 0;
