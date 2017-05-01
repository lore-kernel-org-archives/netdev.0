From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/53] netfilter: nf_conntrack: remove double assignment
Date: Mon,  1 May 2017 12:46:46 +0200
Message-ID: <1493635640-24325-20-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49784 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S378866AbdEAKrz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:47:55 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id ED00A209914
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:44 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DCE90FF2D0
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:44 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C8AF9ED32D
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:42 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>

The protonet pointer will unconditionally be rewritten, so just do the
needed assignment first.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 1329e090fd5e..2de6c1fe3261 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -441,9 +441,8 @@ EXPORT_SYMBOL_GPL(nf_ct_l4proto_unregister_one);
 void nf_ct_l4proto_pernet_unregister_one(struct net *net,
 					 struct nf_conntrack_l4proto *l4proto)
 {
-	struct nf_proto_net *pn = NULL;
+	struct nf_proto_net *pn = nf_ct_l4proto_net(net, l4proto);
 
-	pn = nf_ct_l4proto_net(net, l4proto);
 	if (pn == NULL)
 		return;
 
-- 
2.1.4
