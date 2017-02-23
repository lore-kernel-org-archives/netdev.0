From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/8] Fix bug: sometimes valid entries in hash:* types of sets were evicted
Date: Thu, 23 Feb 2017 12:14:05 +0100
Message-ID: <1487848449-2731-5-git-send-email-pablo@netfilter.org>
References: <1487848449-2731-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54922 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751107AbdBWLOY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 06:14:24 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6523EA4194
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 12:14:22 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 53A4EDA85D
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 12:14:22 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E48BCDA84E
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 12:14:18 +0100 (CET)
In-Reply-To: <1487848449-2731-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Wrong index was used and therefore when shrinking a hash bucket at
deleting an entry, valid entries could be evicted as well.
Thanks to Eric Ewanco for the thorough bugreport.

Fixes netfilter bugzilla #1119

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_gen.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 1b05d4a7d5a1..f236c0bc7b3f 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -897,7 +897,7 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 					continue;
 				data = ahash_data(n, j, dsize);
 				memcpy(tmp->value + k * dsize, data, dsize);
-				set_bit(j, tmp->used);
+				set_bit(k, tmp->used);
 				k++;
 			}
 			tmp->pos = k;
-- 
2.1.4
