From: roy.qing.li@gmail.com
Subject: [PATCH net-next] core: simplify the getting percpu of flow_cache
Date: Thu, 28 Mar 2013 20:24:11 +0800
Message-ID: <1364473451-3640-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:54069 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755676Ab3C1MYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 08:24:19 -0400
Received: by mail-bk0-f51.google.com with SMTP id y8so2012286bkt.24
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 05:24:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

replace per_cpu with per_cpu_ptr to save conversion between address and pointer

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/core/flow.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index 7fae135..707fb7b 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -334,7 +334,7 @@ static int flow_cache_percpu_empty(struct flow_cache *fc, int cpu)
 	struct flow_cache_percpu *fcp;
 	int i;
 
-	fcp = &per_cpu(*fc->percpu, cpu);
+	fcp = per_cpu_ptr(fc->percpu, cpu);
 	for (i = 0; i < flow_cache_hash_size(fc); i++)
 		if (!hlist_empty(&fcp->hash_table[i]))
 			return 0;
-- 
1.7.10.4
