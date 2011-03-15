From: kaber@trash.net
Subject: [PATCH 24/37] IPVS: Conditional ip_vs_conntrack_enabled()
Date: Tue, 15 Mar 2011 20:44:04 +0100
Message-ID: <1300218257-26953-25-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49431 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758408Ab1COToc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:44:32 -0400
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

ip_vs_conntrack_enabled() becomes a noop when CONFIG_SYSCTL is undefined.

In preparation for not including sysctl_conntrack in
struct netns_ipvs when CONFIG_SYCTL is not defined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 77ebece..299aeb5 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1359,7 +1359,11 @@ static inline void ip_vs_notrack(struct sk_buff *skb)
  */
 static inline int ip_vs_conntrack_enabled(struct netns_ipvs *ipvs)
 {
+#ifdef CONFIG_SYSCTL
 	return ipvs->sysctl_conntrack;
+#else
+	return 0;
+#endif
 }
 
 extern void ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp,
-- 
1.7.2.3

