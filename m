From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/2] net: Remove redundant null check before kfree in dev.c
Date: Tue, 20 Nov 2012 16:27:04 +0530
Message-ID: <1353409024-28853-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, edumazet@google.com, sachin.kamat@linaro.org,
	patches@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:35229 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770Ab2KTLDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 06:03:17 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so1197169dak.19
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 03:03:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kfree on a null pointer is a no-op.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 net/core/dev.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 83232a1..c380913 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1075,10 +1075,8 @@ int dev_set_alias(struct net_device *dev, const char *alias, size_t len)
 		return -EINVAL;
 
 	if (!len) {
-		if (dev->ifalias) {
-			kfree(dev->ifalias);
-			dev->ifalias = NULL;
-		}
+		kfree(dev->ifalias);
+		dev->ifalias = NULL;
 		return 0;
 	}
 
-- 
1.7.4.1
