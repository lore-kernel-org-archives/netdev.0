From: Cristian Bercaru <B43982@freescale.com>
Subject: [PATCH] bridging: fix rx_handlers return code
Date: Fri, 8 Mar 2013 19:03:38 +0200
Message-ID: <1362762218-5198-1-git-send-email-B43982@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cristian Bercaru <B43982@freescale.com>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe005.messaging.microsoft.com ([65.55.88.15]:36646 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757848Ab3CHRER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 12:04:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The frames for which rx_handlers return RX_HANDLER_CONSUMED are no longer
counted as dropped. They are counted as successfully received by
'netif_receive_skb'.

This allows network interface drivers to correctly update their RX-OK and
RX-DRP counters based on the result of 'netif_receive_skb'.

Signed-off-by: Cristian Bercaru <B43982@freescale.com>
---
 net/core/dev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 9610389..609ac45 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3444,6 +3444,7 @@ ncls:
 		}
 		switch (rx_handler(&skb)) {
 		case RX_HANDLER_CONSUMED:
+			ret = NET_RX_SUCCESS;
 			goto unlock;
 		case RX_HANDLER_ANOTHER:
 			goto another_round;
-- 
1.7.11.7
