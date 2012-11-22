From: pablo@netfilter.org
Subject: [PATCH 2/2] netfilter: cttimeout: fix buffer overflow
Date: Thu, 22 Nov 2012 10:10:52 +0100
Message-ID: <1353575452-3127-3-git-send-email-pablo@netfilter.org>
References: <1353575452-3127-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52524 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757155Ab2KVURq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 15:17:46 -0500
In-Reply-To: <1353575452-3127-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Chen Gang reports:
the length of nla_data(cda[CTA_TIMEOUT_NAME]) is not limited in server side.

And indeed, its used to strcpy to a fixed-sized buffer.

Fortunately, nfnetlink users need CAP_NET_ADMIN.

Reported-by: Chen Gang <gang.chen@asianux.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_cttimeout.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 8847b4d..701c88a 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -41,7 +41,8 @@ MODULE_DESCRIPTION("cttimeout: Extended Netfilter Connection Tracking timeout tu
 static LIST_HEAD(cttimeout_list);
 
 static const struct nla_policy cttimeout_nla_policy[CTA_TIMEOUT_MAX+1] = {
-	[CTA_TIMEOUT_NAME]	= { .type = NLA_NUL_STRING },
+	[CTA_TIMEOUT_NAME]	= { .type = NLA_NUL_STRING,
+				    .len  = CTNL_TIMEOUT_NAME_MAX - 1},
 	[CTA_TIMEOUT_L3PROTO]	= { .type = NLA_U16 },
 	[CTA_TIMEOUT_L4PROTO]	= { .type = NLA_U8 },
 	[CTA_TIMEOUT_DATA]	= { .type = NLA_NESTED },
-- 
1.7.10.4
