From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2 3/4] cls_rsvp: add sanity check for the packet length
Date: Wed,  4 Aug 2010 22:55:40 +0800
Message-ID: <1280933740-17480-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:39136 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757728Ab0HDO4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 10:56:05 -0400
Received: by pzk26 with SMTP id 26so2020618pzk.19
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 07:56:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The packet length should be checked before the packet data is dereferenced.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
v2: use pskb_network_may_pull()
 net/sched/cls_rsvp.h |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index dd9414e..425a179 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -143,9 +143,17 @@ static int rsvp_classify(struct sk_buff *skb, struct tcf_proto *tp,
 	u8 tunnelid = 0;
 	u8 *xprt;
 #if RSVP_DST_LEN == 4
-	struct ipv6hdr *nhptr = ipv6_hdr(skb);
+	struct ipv6hdr *nhptr;
+
+	if (!pskb_network_may_pull(skb, sizeof(*nhptr)))
+		return -1;
+	nhptr = ipv6_hdr(skb);
 #else
-	struct iphdr *nhptr = ip_hdr(skb);
+	struct iphdr *nhptr;
+
+	if (!pskb_network_may_pull(skb, sizeof(*nhptr)))
+		return -1;
+	nhptr = ip_hdr(skb);
 #endif
 
 restart:
