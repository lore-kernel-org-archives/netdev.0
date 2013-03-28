From: roy.qing.li@gmail.com
Subject: [PATCH] core: fix the use of this_cpu_ptr
Date: Thu, 28 Mar 2013 17:42:41 +0800
Message-ID: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f53.google.com ([209.85.214.53]:56252 "EHLO
	mail-bk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754879Ab3C1Jmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 05:42:50 -0400
Received: by mail-bk0-f53.google.com with SMTP id e19so2208767bku.12
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 02:42:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

flush_tasklet is not percpu var, and percpu is percpu var, and
	this_cpu_ptr(&info->cache->percpu->flush_tasklet)
is not equal to
	&this_cpu_ptr(info->cache->percpu)->flush_tasklet

1f743b076(use this_cpu_ptr per-cpu helper) introduced this bug.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/core/flow.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index 7fae135..e8084b8 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -346,7 +346,7 @@ static void flow_cache_flush_per_cpu(void *data)
 	struct flow_flush_info *info = data;
 	struct tasklet_struct *tasklet;
 
-	tasklet = this_cpu_ptr(&info->cache->percpu->flush_tasklet);
+	tasklet = &this_cpu_ptr(info->cache->percpu)->flush_tasklet;
 	tasklet->data = (unsigned long)info;
 	tasklet_schedule(tasklet);
 }
-- 
1.7.10.4
