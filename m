From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] rhashtable: Warn if min_size or max_size are not a power of two
Date: Thu, 19 Mar 2015 17:34:39 +0100
Message-ID: <29119e13cd16d4a98b4ed6806bec2683943bcd5f.1426782799.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33582 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307AbbCSQeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 12:34:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code correctly limits table size to the next power of two.
This check is solely to catch programming errors.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 5f8fe3e..ad218d6 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -933,6 +933,11 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	if (params->nulls_base && params->nulls_base < (1U << RHT_BASE_SHIFT))
 		return -EINVAL;
 
+	WARN_ON(params->min_size &&
+		roundup_pow_of_two(params->min_size) != params->min_size);
+	WARN_ON(params->max_size &&
+		roundup_pow_of_two(params->max_size) != params->max_size);
+
 	params->min_size = max(params->min_size, HASH_MIN_SIZE);
 
 	if (params->nelem_hint)
-- 
1.9.3
