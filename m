From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv3 net-next 04/10] dst: Add __skb_dst_copy() variation
Date: Tue, 11 Aug 2015 15:59:15 -0700
Message-ID: <1439333961-24474-5-git-send-email-joestringer@nicira.com>
References: <1439333961-24474-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	jpettit@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	jesse@nicira.com, fwestpha@redhat.com, hannes@redhat.com,
	tgraf@noironetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439333961-24474-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This variation on skb_dst_copy() doesn't require two skbs.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 include/net/dst.h | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 2578811..0539940 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -285,13 +285,18 @@ static inline void skb_dst_drop(struct sk_buff *skb)
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
