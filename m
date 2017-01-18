From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 1/3] net: remove duplicate code.
Date: Wed, 18 Jan 2017 15:02:49 -0800
Message-ID: <20170118230249.20744-1-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34518 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751059AbdARXLa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 18:11:30 -0500
Received: by mail-pf0-f193.google.com with SMTP id y143so1943245pfb.1
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 15:10:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

netdev_rx_handler_register() checks to see if the handler is already
busy which was recently separated into netdev_is_rx_handler_busy(). So
use the same function inside register() to avoid code duplication.
Essentially this change should be a no-op

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/core/dev.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ad5959e56116..c8f1f67ff16c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3961,9 +3961,7 @@ int netdev_rx_handler_register(struct net_device *dev,
 			       rx_handler_func_t *rx_handler,
 			       void *rx_handler_data)
 {
-	ASSERT_RTNL();
-
-	if (dev->rx_handler)
+	if (netdev_is_rx_handler_busy(dev))
 		return -EBUSY;
 
 	/* Note: rx_handler_data must be set before rx_handler */
-- 
2.11.0.483.g087da7b7c-goog
