From: Christophe JAILLET <christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>
Subject: [PATCH] RDS: Simplify code
Date: Sat,  3 Sep 2016 07:33:29 +0200
Message-ID: <1472880809-29216-1-git-send-email-christophe.jaillet@wanadoo.fr>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Christophe JAILLET <christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>
To: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Calling 'list_splice' followed by 'INIT_LIST_HEAD' is equivalent to
'list_splice_init'.

This has been spotted with the following coccinelle script:
/////
@@
expression y,z;
@@

-   list_splice(y,z);
-   INIT_LIST_HEAD(y);
+   list_splice_init(y,z);

Signed-off-by: Christophe JAILLET <christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>
---
 net/rds/loop.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/rds/loop.c b/net/rds/loop.c
index f2bf78de5688..c3e6da4fdf97 100644
--- a/net/rds/loop.c
+++ b/net/rds/loop.c
@@ -167,8 +167,7 @@ void rds_loop_exit(void)
 
 	/* avoid calling conn_destroy with irqs off */
 	spin_lock_irq(&loop_conns_lock);
-	list_splice(&loop_conns, &tmp_list);
-	INIT_LIST_HEAD(&loop_conns);
+	list_splice_init(&loop_conns, &tmp_list);
 	spin_unlock_irq(&loop_conns_lock);
 
 	list_for_each_entry_safe(lc, _lc, &tmp_list, loop_node) {
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
