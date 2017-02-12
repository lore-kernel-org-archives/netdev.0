From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/21] netfilter: nf_tables: add check_genid to the nfnetlink subsystem
Date: Sun, 12 Feb 2017 20:42:50 +0100
Message-ID: <1486928573-24773-19-git-send-email-pablo@netfilter.org>
References: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60444 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751443AbdBLTnY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 14:43:24 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 8D734BA6E6
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:23 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7E6CDDA853
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:23 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 53D23DA847
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:21 +0100 (CET)
In-Reply-To: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the check generation id as provided by nfnetlink.
This allows us to reject ruleset updates against stale baseline, so
userspace can retry update with a fresh ruleset cache.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index cb6ae46f6c48..71c60a04b66b 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4972,6 +4972,11 @@ static int nf_tables_abort(struct net *net, struct sk_buff *skb)
 	return 0;
 }
 
+static bool nf_tables_valid_genid(struct net *net, u32 genid)
+{
+	return net->nft.base_seq == genid;
+}
+
 static const struct nfnetlink_subsystem nf_tables_subsys = {
 	.name		= "nf_tables",
 	.subsys_id	= NFNL_SUBSYS_NFTABLES,
@@ -4979,6 +4984,7 @@ static const struct nfnetlink_subsystem nf_tables_subsys = {
 	.cb		= nf_tables_cb,
 	.commit		= nf_tables_commit,
 	.abort		= nf_tables_abort,
+	.valid_genid	= nf_tables_valid_genid,
 };
 
 int nft_chain_validate_dependency(const struct nft_chain *chain,
-- 
2.1.4
