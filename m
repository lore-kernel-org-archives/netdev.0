From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/9] tg3: Remove short DMA check for 1st
 fragment
Date: Wed, 27 Jul 2011 17:20:48 -0700
Message-ID: <1311812454-18197-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4052 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751435Ab1G1AR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2011 20:17:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first fragment of an skb should always be greater than 8 bytes.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 8dfde34..0f5bcf7 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6168,9 +6168,6 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	would_hit_hwbug = 0;
 
-	if (tg3_flag(tp, SHORT_DMA_BUG) && len <= 8)
-		would_hit_hwbug = 1;
-
 	if (tg3_4g_overflow_test(mapping, len))
 		would_hit_hwbug = 1;
 
-- 
1.7.3.4


