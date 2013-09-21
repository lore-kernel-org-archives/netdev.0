From: Nate Levesque <thenaterhood@gmail.com>
Subject: [net-next] Fix hardcoded interrupt name lp->name to use system device value
Date: Sat, 21 Sep 2013 18:49:41 +0000
Message-ID: <1379789381-3992-1-git-send-email-thenaterhood@gmail.com>
Cc: Nate Levesque <thenaterhood@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f41.google.com ([209.85.128.41]:32808 "EHLO
	mail-qe0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278Ab3IUStx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 14:49:53 -0400
Received: by mail-qe0-f41.google.com with SMTP id 1so1131955qee.28
        for <netdev@vger.kernel.org>; Sat, 21 Sep 2013 11:49:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lance interrupt handler was using the hard-coded name which would make it difficult to tell where the interrupt came from. Changed to use the device name that made the interrupt.

Signed-off-by: Nate Levesque <thenaterhood@gmail.com>
---
 drivers/net/ethernet/amd/lance.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet/amd/lance.c
index 5c72843..256f590 100644
--- a/drivers/net/ethernet/amd/lance.c
+++ b/drivers/net/ethernet/amd/lance.c
@@ -754,7 +754,7 @@ lance_open(struct net_device *dev)
 	int i;
 
 	if (dev->irq == 0 ||
-		request_irq(dev->irq, lance_interrupt, 0, lp->name, dev)) {
+		request_irq(dev->irq, lance_interrupt, 0, dev->name, dev)) {
 		return -EAGAIN;
 	}
 
-- 
1.8.1.2
