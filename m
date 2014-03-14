From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next] flowcache: Tune per cpu flow cache shrink size
Date: Fri, 14 Mar 2014 15:42:46 +0800
Message-ID: <1394782966-9792-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57148 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755133AbaCNHml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 03:42:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When per cpu flow cache entries count reaches over high_watermark,
flow cache will be shrinked gently to around low_watermark, not
brutally killing most of cached entries by left only two.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/core/flow.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index 31cfb365e0c6..e379cdcd699b 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -142,7 +142,7 @@ static void __flow_cache_shrink(struct flow_cache *fc,
 static void flow_cache_shrink(struct flow_cache *fc,
 			      struct flow_cache_percpu *fcp)
 {
-	int shrink_to = fc->low_watermark / flow_cache_hash_size(fc);
+	int shrink_to = fc->low_watermark;
 
 	__flow_cache_shrink(fc, fcp, shrink_to);
 }
-- 
1.7.9.5
