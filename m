From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/7] netfilter: nf_tables: check for overflow of rule dlen field
Date: Thu,  5 Mar 2015 21:48:47 +0100
Message-ID: <1425588529-4573-6-git-send-email-pablo@netfilter.org>
References: <1425588529-4573-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34461 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753497AbbCEUpX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 15:45:23 -0500
In-Reply-To: <1425588529-4573-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Check that the space required for the expressions doesn't exceed the
size of the dlen field, which would lead to the iterators crashing.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 6fb532b..7baafd5 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1968,6 +1968,10 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 			n++;
 		}
 	}
+	/* Check for overflow of dlen field */
+	err = -EFBIG;
+	if (size >= 1 << 12)
+		goto err1;
 
 	if (nla[NFTA_RULE_USERDATA])
 		ulen = nla_len(nla[NFTA_RULE_USERDATA]);
-- 
1.7.10.4
