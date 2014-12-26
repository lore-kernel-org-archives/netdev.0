From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 8/27] wireless: cw1200: Use setup_timer
Date: Fri, 26 Dec 2014 15:35:37 +0100
Message-ID: <1419604558-29743-7-git-send-email-Julia.Lawall@lip6.fr>
References: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Solomon Peachy <pizza@shaftnet.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
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

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wireless/cw1200/pm.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/cw1200/pm.c b/drivers/net/wireless/cw1200/pm.c
index 6907c8f..d2202ae 100644
--- a/drivers/net/wireless/cw1200/pm.c
+++ b/drivers/net/wireless/cw1200/pm.c
@@ -101,9 +101,8 @@ int cw1200_pm_init(struct cw1200_pm_state *pm,
 {
 	spin_lock_init(&pm->lock);
 
-	init_timer(&pm->stay_awake);
-	pm->stay_awake.data = (unsigned long)pm;
-	pm->stay_awake.function = cw1200_pm_stay_awake_tmo;
+	setup_timer(&pm->stay_awake, cw1200_pm_stay_awake_tmo,
+		    (unsigned long)pm);
 
 	return 0;
 }

