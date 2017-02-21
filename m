From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: napi_watchdog() can use napi_schedule_irqoff()
Date: Tue, 21 Feb 2017 08:20:56 -0800
Message-ID: <1487694056.9415.27.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36157 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751418AbdBUQU7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 11:20:59 -0500
Received: by mail-pg0-f67.google.com with SMTP id z128so212943pgb.3
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 08:20:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

hrtimer handlers run with masked hard IRQ, we can therefore
use napi_schedule_irqoff()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 05d19c6acf9460e072195e185b64e19088de13da..304f2deae5f9897e60a79ed8b69d6ef208295ded 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5089,7 +5089,7 @@ static enum hrtimer_restart napi_watchdog(struct hrtimer *timer)
 
 	napi = container_of(timer, struct napi_struct, timer);
 	if (napi->gro_list)
-		napi_schedule(napi);
+		napi_schedule_irqoff(napi);
 
 	return HRTIMER_NORESTART;
 }
