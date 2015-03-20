From: rongqing.li@windriver.com
Subject: [PATCH][net-next] rhashtable: ensure that ht->p.min_size is round up to the power of two
Date: Fri, 20 Mar 2015 16:13:57 +0800
Message-ID: <1426839237-10345-1-git-send-email-rongqing.li@windriver.com>
To: netdev@vger.kernel.org, tgraf@suug.ch, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55379 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbbCTIPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 04:15:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

ht->p.min_size will be reset to params->min_size, which has been set
to the params->min_size round up of the power of two, should be kept

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 lib/rhashtable.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index e75c48d..fda169b 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -946,7 +946,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	if (params->max_size)
 		ht->p.max_size = rounddown_pow_of_two(params->max_size);
 
-	ht->p.min_size = max(params->min_size, HASH_MIN_SIZE);
+	ht->p.min_size = max(ht->p.min_size, HASH_MIN_SIZE);
 
 	if (params->locks_mul)
 		ht->p.locks_mul = roundup_pow_of_two(params->locks_mul);
-- 
2.1.0
