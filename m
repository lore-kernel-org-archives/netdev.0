From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/13] netfilter: nf_tables: remove unused variable in nf_tables_dump_set()
Date: Mon,  6 Jan 2014 14:46:41 +0100
Message-ID: <1389016002-9116-13-git-send-email-pablo@netfilter.org>
References: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59569 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754752AbaAFNrC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 08:47:02 -0500
In-Reply-To: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Nazarewicz <mina86@mina86.com>

The nfmsg variable is not used (except in sizeof operator which does
not care about its value) between the first and second time it is
assigned the value.  Furthermore, nlmsg_data has no side effects, so
the assignment can be safely removed.

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index aa4df58..37f0e69 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2505,9 +2505,8 @@ static int nf_tables_dump_set(struct sk_buff *skb, struct netlink_callback *cb)
 	u32 portid, seq;
 	int event, err;
 
-	nfmsg = nlmsg_data(cb->nlh);
-	err = nlmsg_parse(cb->nlh, sizeof(*nfmsg), nla, NFTA_SET_ELEM_LIST_MAX,
-			  nft_set_elem_list_policy);
+	err = nlmsg_parse(cb->nlh, sizeof(struct nfgenmsg), nla,
+			  NFTA_SET_ELEM_LIST_MAX, nft_set_elem_list_policy);
 	if (err < 0)
 		return err;
 
-- 
1.7.10.4
