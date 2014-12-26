From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 11/27] ksz884x: Use setup_timer
Date: Fri, 26 Dec 2014 15:35:42 +0100
Message-ID: <1419604558-29743-12-git-send-email-Julia.Lawall@lip6.fr>
References: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
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
-t.function = f;
-t.data = d;
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/micrel/ksz884x.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index f1ebed6..d484f59 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4348,9 +4348,7 @@ static void ksz_init_timer(struct ksz_timer_info *info, int period,
 {
 	info->max = 0;
 	info->period = period;
-	init_timer(&info->timer);
-	info->timer.function = function;
-	info->timer.data = (unsigned long) data;
+	setup_timer(&info->timer, function, (unsigned long)data);
 }
 
 static void ksz_update_timer(struct ksz_timer_info *info)
