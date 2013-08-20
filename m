From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/3] net: ipv6: mcast: minor: use defines for rfc3810/8.1 lengths
Date: Tue, 20 Aug 2013 12:22:02 +0200
Message-ID: <1376994122-3022-4-git-send-email-dborkman@redhat.com>
References: <1376994122-3022-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4131 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750937Ab3HTKWL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:22:11 -0400
In-Reply-To: <1376994122-3022-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of hard-coding length values, use a define to make it clear
where those lengths come from.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv6/mcast.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 33f98d9..98ead2b 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -107,9 +107,12 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
 			    struct inet6_dev *idev);
 
-
 #define MLD_QRV_DEFAULT		2
 
+/* RFC3810, 8.1 Query Version Distinctions */
+#define MLD_V1_QUERY_LEN	24
+#define MLD_V2_QUERY_LEN_MIN	28
+
 #define MLD_V1_SEEN(idev) (dev_net((idev)->dev)->ipv6.devconf_all->force_mld_version == 1 || \
 		(idev)->cnf.force_mld_version == 1 || \
 		((idev)->mc_v1_seen && \
@@ -1146,7 +1149,7 @@ int igmp6_event_query(struct sk_buff *skb)
 	    !(group_type&IPV6_ADDR_MULTICAST))
 		return -EINVAL;
 
-	if (len == 24) {
+	if (len == MLD_V1_QUERY_LEN) {
 		int switchback;
 		/* MLDv1 router present */
 
@@ -1160,7 +1163,7 @@ int igmp6_event_query(struct sk_buff *skb)
 			__in6_dev_put(idev);
 		/* clear deleted report items */
 		mld_clear_delrec(idev);
-	} else if (len >= 28) {
+	} else if (len >= MLD_V2_QUERY_LEN_MIN) {
 		int srcs_offset = sizeof(struct mld2_query) -
 				  sizeof(struct icmp6hdr);
 		if (!pskb_may_pull(skb, srcs_offset))
-- 
1.7.11.7
