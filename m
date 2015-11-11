From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/10] netfilter: ipset: Fix hash:* type expiration
Date: Wed, 11 Nov 2015 18:33:37 +0100
Message-ID: <1447263223-22662-5-git-send-email-pablo@netfilter.org>
References: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48405 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752643AbbKKRd7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2015 12:33:59 -0500
Received: from antivirus1-rhel7.int (antivirus1.int [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 813E51392B9
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:58 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 7158F5DC
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:58 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 20D8E5DC
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:53 +0100 (CET)
In-Reply-To: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Incorrect index was used when the data blob was shrinked at expiration,
which could lead to falsely expired entries and memory leak when
the comment extension was used too.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_gen.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 4ff2219..fa4f637 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -523,7 +523,7 @@ mtype_expire(struct ip_set *set, struct htype *h, u8 nets_length, size_t dsize)
 					continue;
 				data = ahash_data(n, j, dsize);
 				memcpy(tmp->value + d * dsize, data, dsize);
-				set_bit(j, tmp->used);
+				set_bit(d, tmp->used);
 				d++;
 			}
 			tmp->pos = d;
-- 
2.1.4
