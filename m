From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 6/7] hsr: replace del_timer by del_timer_sync
Date: Wed, 26 Mar 2014 22:33:44 +0100
Message-ID: <1395869625-15209-7-git-send-email-Julia.Lawall@lip6.fr>
References: <1395869625-15209-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, tglx@linutronix.de,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arvid Brodin <arvid.brodin@alten.se>
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

 net/hsr/hsr_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/hsr/hsr_main.c b/net/hsr/hsr_main.c
index 10010c5..3fee521 100644
--- a/net/hsr/hsr_main.c
+++ b/net/hsr/hsr_main.c
@@ -459,7 +459,7 @@ static int __init hsr_init(void)
 static void __exit hsr_exit(void)
 {
 	unregister_netdevice_notifier(&hsr_nb);
-	del_timer(&prune_timer);
+	del_timer_sync(&prune_timer);
 	hsr_netlink_exit();
 	dev_remove_pack(&hsr_pt);
 }
