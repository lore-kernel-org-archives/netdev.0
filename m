From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] wd: fix memory leak
Date: Tue, 13 Jul 2010 15:23:12 +0400
Message-ID: <1279020192-9484-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:54679 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754822Ab0GMLXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 07:23:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unmap mapped IO in wd_probe1() if register_netdev() failed.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/wd.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wd.c b/drivers/net/wd.c
index 746a5ee..eb72c67 100644
--- a/drivers/net/wd.c
+++ b/drivers/net/wd.c
@@ -358,8 +358,10 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 #endif
 
 	err = register_netdev(dev);
-	if (err)
+	if (err) {
 		free_irq(dev->irq, dev);
+		iounmap(ei_status.mem);
+	}
 	return err;
 }
 
-- 
1.7.0.4

