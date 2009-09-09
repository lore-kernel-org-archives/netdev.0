From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] dm9000: Use resource_size instead of private macro
Date: Wed,  9 Sep 2009 13:07:43 +0200
Message-ID: <1252494464-4633-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org, Tobias Klauser <tklauser@distanz.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:49148 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751698AbZIILHl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2009 07:07:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macro res_size in drivers/net/dm9000.c is a copy of resource_size in
linux/ioport.h. Remove the function and use resource_size instead.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/dm9000.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index dd771de..00a9db8 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -1185,8 +1185,6 @@ static const struct net_device_ops dm9000_netdev_ops = {
 #endif
 };
 
-#define res_size(_r) (((_r)->end - (_r)->start) + 1)
-
 /*
  * Search DM9000 board, allocate space and register it
  */
@@ -1236,7 +1234,7 @@ dm9000_probe(struct platform_device *pdev)
 		goto out;
 	}
 
-	iosize = res_size(db->addr_res);
+	iosize = resource_size(db->addr_res);
 	db->addr_req = request_mem_region(db->addr_res->start, iosize,
 					  pdev->name);
 
@@ -1254,7 +1252,7 @@ dm9000_probe(struct platform_device *pdev)
 		goto out;
 	}
 
-	iosize = res_size(db->data_res);
+	iosize = resource_size(db->data_res);
 	db->data_req = request_mem_region(db->data_res->start, iosize,
 					  pdev->name);
 
-- 
1.6.0.4

