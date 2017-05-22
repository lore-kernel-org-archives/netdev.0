From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] net/core: remove explicit do_softirq() from busy_poll_stop()
Date: Mon, 22 May 2017 21:26:41 +0200
Message-ID: <20170522192641.hylqmhb7t2fykk5e@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        tglx@linutronix.de
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:50019 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758616AbdEVT0v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 15:26:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 217f69743681 ("net: busy-poll: allow preemption in
sk_busy_loop()") there is an explicit do_softirq() invocation after
local_bh_enable() has been invoked.
I don't understand why we need this because local_bh_enable() will
invoke do_softirq() once the softirq counter reached zero and we have
softirq-related work pending.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 net/core/dev.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index fca407b4a6ea..e84eb0ec5529 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5199,8 +5199,6 @@ static void busy_poll_stop(struct napi_struct *napi, void *have_poll_lock)
 	if (rc == BUSY_POLL_BUDGET)
 		__napi_schedule(napi);
 	local_bh_enable();
-	if (local_softirq_pending())
-		do_softirq();
 }
 
 void napi_busy_loop(unsigned int napi_id,
-- 
2.11.0
