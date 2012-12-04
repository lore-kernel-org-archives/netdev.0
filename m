From: pablo@netfilter.org
Subject: [PATCH 5/6] netfilter: ctnetlink: nla_policy updates
Date: Tue,  4 Dec 2012 18:31:32 +0100
Message-ID: <1354642293-4114-6-git-send-email-pablo@netfilter.org>
References: <1354642293-4114-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54465 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754417Ab2LDRb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 12:31:59 -0500
In-Reply-To: <1354642293-4114-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Add stricter checking for a few attributes.
Note that these changes don't fix any bug in the current code base.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c   |    8 ++++++--
 net/netfilter/nf_conntrack_proto_tcp.c |    2 ++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index c24a00a..4e078cd 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -898,7 +898,8 @@ ctnetlink_parse_zone(const struct nlattr *attr, u16 *zone)
 }
 
 static const struct nla_policy help_nla_policy[CTA_HELP_MAX+1] = {
-	[CTA_HELP_NAME]		= { .type = NLA_NUL_STRING },
+	[CTA_HELP_NAME]		= { .type = NLA_NUL_STRING,
+				    .len = NF_CT_HELPER_NAME_LEN - 1 },
 };
 
 static inline int
@@ -932,6 +933,8 @@ static const struct nla_policy ct_nla_policy[CTA_MAX+1] = {
 	[CTA_ID]		= { .type = NLA_U32 },
 	[CTA_NAT_DST]		= { .type = NLA_NESTED },
 	[CTA_TUPLE_MASTER]	= { .type = NLA_NESTED },
+	[CTA_NAT_SEQ_ADJ_ORIG]  = { .type = NLA_NESTED },
+	[CTA_NAT_SEQ_ADJ_REPLY] = { .type = NLA_NESTED },
 	[CTA_ZONE]		= { .type = NLA_U16 },
 	[CTA_MARK_MASK]		= { .type = NLA_U32 },
 };
@@ -2322,7 +2325,8 @@ static const struct nla_policy exp_nla_policy[CTA_EXPECT_MAX+1] = {
 	[CTA_EXPECT_MASK]	= { .type = NLA_NESTED },
 	[CTA_EXPECT_TIMEOUT]	= { .type = NLA_U32 },
 	[CTA_EXPECT_ID]		= { .type = NLA_U32 },
-	[CTA_EXPECT_HELP_NAME]	= { .type = NLA_NUL_STRING },
+	[CTA_EXPECT_HELP_NAME]	= { .type = NLA_NUL_STRING,
+				    .len = NF_CT_HELPER_NAME_LEN - 1 },
 	[CTA_EXPECT_ZONE]	= { .type = NLA_U16 },
 	[CTA_EXPECT_FLAGS]	= { .type = NLA_U32 },
 	[CTA_EXPECT_CLASS]	= { .type = NLA_U32 },
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 61f9285..83876e9 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1353,6 +1353,8 @@ static const struct nla_policy tcp_timeout_nla_policy[CTA_TIMEOUT_TCP_MAX+1] = {
 	[CTA_TIMEOUT_TCP_TIME_WAIT]	= { .type = NLA_U32 },
 	[CTA_TIMEOUT_TCP_CLOSE]		= { .type = NLA_U32 },
 	[CTA_TIMEOUT_TCP_SYN_SENT2]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_TCP_RETRANS]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_TCP_UNACK]		= { .type = NLA_U32 },
 };
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
-- 
1.7.10.4
