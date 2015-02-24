From: Josh Hunt <johunt@akamai.com>
Subject: [PATCH v2 1/2] rhashtable: require max_shift if grow_decision defined
Date: Tue, 24 Feb 2015 11:10:57 -0500
Message-ID: <1424794259-30241-2-git-send-email-johunt@akamai.com>
References: <1424794259-30241-1-git-send-email-johunt@akamai.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Josh Hunt <johunt@akamai.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay08.akamai.com ([96.6.114.112]:46259 "EHLO
	prod-mail-xrelay08.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752447AbbBXQLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 11:11:02 -0500
In-Reply-To: <1424794259-30241-1-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an rhashtable user defines a grow_decision fn they must also define a
max_shift parameter.

Signed-off-by: Josh Hunt <johunt@akamai.com>
---
 lib/rhashtable.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 9cc4c4a..7d6f539 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -1077,7 +1077,8 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	size = HASH_DEFAULT_SIZE;
 
 	if ((params->key_len && !params->hashfn) ||
-	    (!params->key_len && !params->obj_hashfn))
+	    (!params->key_len && !params->obj_hashfn) ||
+	    (params->grow_decision && !params->max_shift))
 		return -EINVAL;
 
 	if (params->nulls_base && params->nulls_base < (1U << RHT_BASE_SHIFT))
-- 
1.7.9.5
