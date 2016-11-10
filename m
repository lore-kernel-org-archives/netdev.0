From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/14] netfilter: conntrack: avoid excess memory allocation
Date: Thu, 10 Nov 2016 01:23:39 +0100
Message-ID: <1478737427-1574-7-git-send-email-pablo@netfilter.org>
References: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37764 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753161AbcKJAYH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 19:24:07 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 3B29796627
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:06 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2AFC4DA795
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:06 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 59309DA808
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:02 +0100 (CET)
In-Reply-To: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

This is now a fixed-size extension, so we don't need to pass a variable
alloc size.  This (harmless) error results in allocating 32 instead of
the needed 16 bytes for this extension as the size gets passed twice.

Fixes: 23014011ba420 ("netfilter: conntrack: support a fixed size of 128 distinct labels")
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_labels.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_labels.h b/include/net/netfilter/nf_conntrack_labels.h
index 498814626e28..1723a67c0b0a 100644
--- a/include/net/netfilter/nf_conntrack_labels.h
+++ b/include/net/netfilter/nf_conntrack_labels.h
@@ -30,8 +30,7 @@ static inline struct nf_conn_labels *nf_ct_labels_ext_add(struct nf_conn *ct)
 	if (net->ct.labels_used == 0)
 		return NULL;
 
-	return nf_ct_ext_add_length(ct, NF_CT_EXT_LABELS,
-				    sizeof(struct nf_conn_labels), GFP_ATOMIC);
+	return nf_ct_ext_add(ct, NF_CT_EXT_LABELS, GFP_ATOMIC);
 #else
 	return NULL;
 #endif
-- 
2.1.4
