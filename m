From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/7] atm: replace del_timer by del_timer_sync
Date: Wed, 26 Mar 2014 22:33:40 +0100
Message-ID: <1395869625-15209-3-git-send-email-Julia.Lawall@lip6.fr>
References: <1395869625-15209-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, tglx@linutronix.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395869625-15209-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Use del_timer_sync to ensure that the timer is stopped on all CPUs before
the driver exists.

This change was suggested by Thomas Gleixner.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r@
declarer name module_exit;
identifier ex;
@@

module_exit(ex);

@@
identifier r.ex;
@@

ex(...) {
  <...
- del_timer
+ del_timer_sync
    (...)
  ...>
}
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
Not tested.

 net/atm/mpc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index b71ff6b..91dc58f 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -1492,7 +1492,7 @@ static void __exit atm_mpoa_cleanup(void)
 
 	mpc_proc_clean();
 
-	del_timer(&mpc_timer);
+	del_timer_sync(&mpc_timer);
 	unregister_netdevice_notifier(&mpoa_notifier);
 	deregister_atm_ioctl(&atm_ioctl_ops);
 
