From: akpm@osdl.org
Subject: [patch 1/1] err1-62: ax25_ds_idletimer_expiry() locking fix
Date: Fri, 02 Jul 2004 01:28:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407020829.i628TNG20391@mail.osdl.org>
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Fix deadlock identified by the Stanford locking checker.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/ax25/ax25_ds_timer.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/ax25/ax25_ds_timer.c~err1-62-ax25_ds_idletimer_expiry-locking-fix net/ax25/ax25_ds_timer.c
--- 25/net/ax25/ax25_ds_timer.c~err1-62-ax25_ds_idletimer_expiry-locking-fix	2004-07-02 01:27:07.504239472 -0700
+++ 25-akpm/net/ax25/ax25_ds_timer.c	2004-07-02 01:27:11.824582680 -0700
@@ -180,7 +180,7 @@ void ax25_ds_idletimer_expiry(ax25_cb *a
 			ax25->sk->sk_state_change(ax25->sk);
 			sock_set_flag(ax25->sk, SOCK_DEAD);
 		}
-		bh_lock_sock(ax25->sk);
+		bh_unlock_sock(ax25->sk);
 	}
 }
 
_
