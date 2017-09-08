From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 8/9] netfilter: xt_hashlimit: alloc hashtable with right size
Date: Fri,  8 Sep 2017 19:45:47 +0200
Message-ID: <1504892748-1605-9-git-send-email-pablo@netfilter.org>
References: <1504892748-1605-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54520 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756791AbdIHRqG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 13:46:06 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 7A5608D0515
        for <netdev@vger.kernel.org>; Fri,  8 Sep 2017 19:45:35 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6CBA6DA2DA
        for <netdev@vger.kernel.org>; Fri,  8 Sep 2017 19:45:35 +0200 (CEST)
In-Reply-To: <1504892748-1605-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhizhou Tian <zhizhou.tian@gmail.com>

struct xt_byteslimit_htable used hlist_head, but memory allocation is
done through sizeof(struct list_head).

Signed-off-by: Zhizhou Tian <zhizhou.tian@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_hashlimit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 10d48234f5f4..962ea4a63d9f 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -279,7 +279,7 @@ static int htable_create(struct net *net, struct hashlimit_cfg3 *cfg,
 		size = cfg->size;
 	} else {
 		size = (totalram_pages << PAGE_SHIFT) / 16384 /
-		       sizeof(struct list_head);
+		       sizeof(struct hlist_head);
 		if (totalram_pages > 1024 * 1024 * 1024 / PAGE_SIZE)
 			size = 8192;
 		if (size < 16)
@@ -287,7 +287,7 @@ static int htable_create(struct net *net, struct hashlimit_cfg3 *cfg,
 	}
 	/* FIXME: don't use vmalloc() here or anywhere else -HW */
 	hinfo = vmalloc(sizeof(struct xt_hashlimit_htable) +
-	                sizeof(struct list_head) * size);
+	                sizeof(struct hlist_head) * size);
 	if (hinfo == NULL)
 		return -ENOMEM;
 	*out_hinfo = hinfo;
-- 
2.1.4
