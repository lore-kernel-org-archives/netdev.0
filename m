From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] net/atm/signaling.c: replace current->state by  __set_current_state()
Date: Mon, 23 Feb 2015 18:31:07 +0100
Message-ID: <1424712667-11849-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Peter Zijlstra <peterz@infradead.org>,
	Fabian Frederick <fabf@skynet.be>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use helper functions to access current->state.
Direct assignments are prone to races and therefore buggy.

Thanks to Peter Zijlstra for the exact definition of the problem.

Suggested-By: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/atm/signaling.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/atm/signaling.c b/net/atm/signaling.c
index 523bce7..0140832 100644
--- a/net/atm/signaling.c
+++ b/net/atm/signaling.c
@@ -40,7 +40,7 @@ static void sigd_put_skb(struct sk_buff *skb)
 		pr_debug("atmsvc: waiting for signaling daemon...\n");
 		schedule();
 	}
-	current->state = TASK_RUNNING;
+	__set_current_state(TASK_RUNNING);
 	remove_wait_queue(&sigd_sleep, &wait);
 #else
 	if (!sigd) {
-- 
2.1.0
