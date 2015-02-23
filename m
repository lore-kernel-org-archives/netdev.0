From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] irda: replace current->state by set_current_state()
Date: Mon, 23 Feb 2015 18:38:24 +0100
Message-ID: <1424713105-12845-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Peter Zijlstra <peterz@infradead.org>,
	Fabian Frederick <fabf@skynet.be>,
	Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use helper functions to access current->state.
Direct assignments are prone to races and therefore buggy.

current->state = TASK_RUNNING can be replaced by __set_current_state()

Thanks to Peter Zijlstra for the exact definition of the problem.

Suggested-By: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/irda/ircomm/ircomm_tty.c | 2 +-
 net/irda/irnet/irnet_ppp.c   | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 40695b9..9940a41 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -811,7 +811,7 @@ static void ircomm_tty_wait_until_sent(struct tty_struct *tty, int timeout)
 			break;
 	}
 	spin_unlock_irqrestore(&self->spinlock, flags);
-	current->state = TASK_RUNNING;
+	__set_current_state(TASK_RUNNING);
 }
 
 /*
diff --git a/net/irda/irnet/irnet_ppp.c b/net/irda/irnet/irnet_ppp.c
index 3c83a1e..1215693 100644
--- a/net/irda/irnet/irnet_ppp.c
+++ b/net/irda/irnet/irnet_ppp.c
@@ -305,7 +305,7 @@ irnet_ctrl_read(irnet_socket *	ap,
 
   /* Put ourselves on the wait queue to be woken up */
   add_wait_queue(&irnet_events.rwait, &wait);
-  current->state = TASK_INTERRUPTIBLE;
+  set_current_state(TASK_INTERRUPTIBLE);
   for(;;)
     {
       /* If there is unread events */
@@ -321,7 +321,7 @@ irnet_ctrl_read(irnet_socket *	ap,
       /* Yield and wait to be woken up */
       schedule();
     }
-  current->state = TASK_RUNNING;
+  __set_current_state(TASK_RUNNING);
   remove_wait_queue(&irnet_events.rwait, &wait);
 
   /* Did we got it ? */
-- 
2.1.0
