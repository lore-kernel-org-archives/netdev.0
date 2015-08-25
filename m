From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv5 net-next 04/10] dst: Add __skb_dst_copy() variation
Date: Mon, 24 Aug 2015 17:32:14 -0700
Message-ID: <1440462740-23358-5-git-send-email-joestringer@nicira.com>
References: <1440462740-23358-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, tgraf@suug.ch,
	jpettit@nicira.com, jesse@nicira.com,
	netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33836 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021AbbHYAcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 20:32:32 -0400
Received: by pdbfa8 with SMTP id fa8so59458755pdb.1
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 17:32:32 -0700 (PDT)
In-Reply-To: <1440462740-23358-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This variation on skb_dst_copy() doesn't require two skbs.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
v4: Add ack.
v5: No change.
---
 include/net/dst.h | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 0a9a723..6f282e7 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -286,13 +286,18 @@ static inline void skb_dst_drop(struct sk_buff *skb)
 	}
 }
 
-static inline void skb_dst_copy(struct sk_buff *nskb, const struct sk_buff *oskb)
+static inline void __skb_dst_copy(struct sk_buff *nskb, unsigned long refdst)
 {
-	nskb->_skb_refdst = oskb->_skb_refdst;
+	nskb->_skb_refdst = refdst;
 	if (!(nskb->_skb_refdst & SKB_DST_NOREF))
 		dst_clone(skb_dst(nskb));
 }
 
+static inline void skb_dst_copy(struct sk_buff *nskb, const struct sk_buff *oskb)
+{
+	__skb_dst_copy(nskb, oskb->_skb_refdst);
+}
+
 /**
  * skb_dst_force - makes sure skb dst is refcounted
  * @skb: buffer
-- 
2.1.4
