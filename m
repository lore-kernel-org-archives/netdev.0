From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next] net: add missing dev_put() in __netdev_adjacent_dev_insert
Date: Wed, 23 Oct 2013 15:28:56 +0200
Message-ID: <1382534936-23080-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751416Ab3JWNcv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 09:32:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think that a dev_put() is needed in the error path to preserve the
proper dev refcount.

CC: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 net/core/dev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0918aad..bdffd65 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4648,6 +4648,7 @@ remove_symlinks:
 
 free_adj:
 	kfree(adj);
+	dev_put(adj_dev);
 
 	return ret;
 }
-- 
1.8.1.4
