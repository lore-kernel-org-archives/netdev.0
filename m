From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: reduce net_rx_action() latency to 2 HZ
Date: Tue, 05 Mar 2013 09:15:13 -0800
Message-ID: <1362503713.15793.121.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:52876 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754951Ab3CERPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 12:15:17 -0500
Received: by mail-pb0-f52.google.com with SMTP id ma3so4728520pbc.39
        for <netdev@vger.kernel.org>; Tue, 05 Mar 2013 09:15:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazt@google.com>

We should use time_after_eq() to get maximum latency of two ticks,
instead of three.

Bug added in commit 24f8b2385 (net: increase receive packet quantum)

Signed-off-by: Eric Dumazet <edumazt@google.com>
---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 18d8b5a..461b315 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4107,7 +4107,7 @@ static void net_rx_action(struct softirq_action *h)
 		 * Allow this to run for 2 jiffies since which will allow
 		 * an average latency of 1.5/HZ.
 		 */
-		if (unlikely(budget <= 0 || time_after(jiffies, time_limit)))
+		if (unlikely(budget <= 0 || time_after_eq(jiffies, time_limit)))
 			goto softnet_break;
 
 		local_irq_enable();
