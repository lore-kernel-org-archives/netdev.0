From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] cls_rsvp: add sanity check for the packet length
Date: Wed,  4 Aug 2010 16:55:24 +0800
Message-ID: <1280912124-30374-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:56410 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207Ab0HDIzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 04:55:47 -0400
Received: by pvc7 with SMTP id 7so1907241pvc.19
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 01:55:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The packet length should be checked before the packet data is dereferenced.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/sched/cls_rsvp.h |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index dd9414e..4fa119d 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -143,9 +143,17 @@ static int rsvp_classify(struct sk_buff *skb, struct tcf_proto *tp,
 	u8 tunnelid = 0;
 	u8 *xprt;
 #if RSVP_DST_LEN == 4
-	struct ipv6hdr *nhptr = ipv6_hdr(skb);
+	struct ipv6hdr *nhptr;
+
+	if (!pskb_may_pull(skb, skb_network_offset(skb) + sizeof(*nhptr)))
+		return -1;
+	nhptr = ipv6_hdr(skb);
 #else
 	struct iphdr *nhptr = ip_hdr(skb);
+
+	if (!pskb_may_pull(skb, skb_network_offset(skb) + sizeof(*nhptr)))
+		return -1;
+	nhptr = ip_hdr(skb);
 #endif
 
 restart:
