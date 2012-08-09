From: kaber@trash.net
Subject: [PATCH 01/19] netfilter: nf_ct_sip: fix helper name
Date: Thu,  9 Aug 2012 22:08:45 +0200
Message-ID: <1344542943-11588-2-git-send-email-kaber@trash.net>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65316 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754723Ab2HIUSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 16:18:37 -0400
In-Reply-To: <1344542943-11588-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Commit 3a8fc53a (netfilter: nf_ct_helper: allocate 16 bytes for the helper
and policy names) introduced a bug in the SIP helper, the helper name is
sprinted to the sip_names array instead of instead of into the helper
structure. This breaks the helper match and the /proc/net/nf_conntrack_expect
output.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_sip.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 758a1ba..2fb6669 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1515,7 +1515,6 @@ static int sip_help_udp(struct sk_buff *skb, unsigned int protoff,
 }
 
 static struct nf_conntrack_helper sip[MAX_PORTS][4] __read_mostly;
-static char sip_names[MAX_PORTS][4][sizeof("sip-65535")] __read_mostly;
 
 static const struct nf_conntrack_expect_policy sip_exp_policy[SIP_EXPECT_MAX + 1] = {
 	[SIP_EXPECT_SIGNALLING] = {
@@ -1585,9 +1584,9 @@ static int __init nf_conntrack_sip_init(void)
 			sip[i][j].me = THIS_MODULE;
 
 			if (ports[i] == SIP_PORT)
-				sprintf(sip_names[i][j], "sip");
+				sprintf(sip[i][j].name, "sip");
 			else
-				sprintf(sip_names[i][j], "sip-%u", i);
+				sprintf(sip[i][j].name, "sip-%u", i);
 
 			pr_debug("port #%u: %u\n", i, ports[i]);
 
-- 
1.7.1
