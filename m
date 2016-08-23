From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH] net: rtnetlink: Don't export empty RTAX_FEATURES
Date: Tue, 23 Aug 2016 13:14:31 +0200
Message-ID: <1471950871-9112-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45635 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757173AbcHWLXL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 07:23:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the features bit field has bits for internal only use as well, it
may happen that the kernel exports RTAX_FEATURES attribute with zero
value which is pointless.

Fix this by making sure the attribute is added only if the exported
value is non-zero.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/core/rtnetlink.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 189cc78c77eba..318fc5231b2b4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -704,6 +704,8 @@ int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics)
 			} else if (i == RTAX_FEATURES - 1) {
 				u32 user_features = metrics[i] & RTAX_FEATURE_MASK;
 
+				if (!user_features)
+					continue;
 				BUILD_BUG_ON(RTAX_FEATURE_MASK & DST_FEATURE_MASK);
 				if (nla_put_u32(skb, i + 1, user_features))
 					goto nla_put_failure;
-- 
2.8.2
