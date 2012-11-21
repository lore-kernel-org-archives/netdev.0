From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/1] netfilter: cttimeout: fix buffer overflow
Date: Wed, 21 Nov 2012 12:37:38 +0100
Message-ID: <1353497858-29404-1-git-send-email-fw@strlen.de>
Cc: netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>
To: netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:32790 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753542Ab2KULgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 06:36:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chen Gang reports:
the length of nla_data(cda[CTA_TIMEOUT_NAME]) is not limited in server side.

And indeed, its used to strcpy to a fixed-sized buffer.

Fortunately, nfnetlink users need CAP_NET_ADMIN.

Reported-by: Chen Gang <gang.chen@asianux.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/netfilter/nfnetlink_cttimeout.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

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
1.7.8.6
