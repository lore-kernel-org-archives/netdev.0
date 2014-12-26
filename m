From: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Subject: [PATCH 17/27] iwl3945: Use setup_timer
Date: Fri, 26 Dec 2014 15:35:49 +0100
Message-ID: <1419604558-29743-19-git-send-email-Julia.Lawall@lip6.fr>
References: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1419604558-29743-1-git-send-email-Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Convert a call to init_timer and accompanying intializations of
the timer's data and function fields to a call to setup_timer.

A simplified version of the semantic match that fixes this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression t,f,d;
@@

-init_timer(&t);
+setup_timer(&t,f,d);
-t.data = d;
-t.function = f;
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>

---
 drivers/net/wireless/iwlegacy/3945-mac.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/wireless/iwlegacy/3945-mac.c
index dc1d20c..e566580 100644
--- a/drivers/net/wireless/iwlegacy/3945-mac.c
+++ b/drivers/net/wireless/iwlegacy/3945-mac.c
@@ -3429,9 +3429,7 @@ il3945_setup_deferred_work(struct il_priv *il)
 
 	il3945_hw_setup_deferred_work(il);
 
-	init_timer(&il->watchdog);
-	il->watchdog.data = (unsigned long)il;
-	il->watchdog.function = il_bg_watchdog;
+	setup_timer(&il->watchdog, il_bg_watchdog, (unsigned long)il);
 
 	tasklet_init(&il->irq_tasklet,
 		     (void (*)(unsigned long))il3945_irq_tasklet,

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
