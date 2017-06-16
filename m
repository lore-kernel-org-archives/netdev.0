From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 2/2] net/core: remove explicit do_softirq() from busy_poll_stop()
Date: Fri, 16 Jun 2017 19:24:00 +0200
Message-ID: <20170616172400.10809-2-bigeasy@linutronix.de>
References: <20170616172400.10809-1-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Thomas Gleixner <tglx@linutronix.de>,
        Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:56430 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751706AbdFPRYJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:24:09 -0400
In-Reply-To: <20170616172400.10809-1-bigeasy@linutronix.de>
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
index b1f8a89322bd..447d37fe89e6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5281,8 +5281,6 @@ static void busy_poll_stop(struct napi_struct *napi, =
void *have_poll_lock)
 	if (rc =3D=3D BUSY_POLL_BUDGET)
 		__napi_schedule(napi);
 	local_bh_enable();
-	if (local_softirq_pending())
-		do_softirq();
 }
=20
 void napi_busy_loop(unsigned int napi_id,
--=20
2.11.0
