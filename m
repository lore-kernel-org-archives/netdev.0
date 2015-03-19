From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next v2] rhashtable: Warn if min_size or max_size are not
 a power of two
Date: Thu, 19 Mar 2015 19:46:08 +0000
Message-ID: <20150319194608.GA27962@casper.infradead.org>
References: <29119e13cd16d4a98b4ed6806bec2683943bcd5f.1426782799.git.tgraf@suug.ch>
 <20150319.152450.1573636653085091157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34708 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbCSTqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 15:46:10 -0400
Content-Disposition: inline
In-Reply-To: <20150319.152450.1573636653085091157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code correctly limits table size to the next power of two.
This check is solely to catch programming errors.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
v2: use is_power_of_2() instead of roundup_pow_of_two()

 lib/rhashtable.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 5f8fe3e..5474507 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -933,6 +933,9 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	if (params->nulls_base && params->nulls_base < (1U << RHT_BASE_SHIFT))
 		return -EINVAL;
 
+	WARN_ON(params->min_size && !is_power_of_2(params->min_size));
+	WARN_ON(params->max_size && !is_power_of_2(params->max_size));
+
 	params->min_size = max(params->min_size, HASH_MIN_SIZE);
 
 	if (params->nelem_hint)
-- 
1.9.3
