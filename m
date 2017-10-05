From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net/cw1200: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:51:01 -0700
Message-ID: <20171005005101.GA23346@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Solomon Peachy <pizza@shaftnet.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Solomon Peachy <pizza@shaftnet.org>
Cc: Kalle Valo <kvalo@codeaurora.org>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 drivers/net/wireless/st/cw1200/pm.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/st/cw1200/pm.c b/drivers/net/wireless/st/cw1200/pm.c
index d2202ae92bdd..ded23df1ac1d 100644
--- a/drivers/net/wireless/st/cw1200/pm.c
+++ b/drivers/net/wireless/st/cw1200/pm.c
@@ -91,7 +91,7 @@ struct cw1200_suspend_state {
 	u8 prev_ps_mode;
 };
 
-static void cw1200_pm_stay_awake_tmo(unsigned long arg)
+static void cw1200_pm_stay_awake_tmo(struct timer_list *unused)
 {
 	/* XXX what's the point of this ? */
 }
@@ -101,8 +101,7 @@ int cw1200_pm_init(struct cw1200_pm_state *pm,
 {
 	spin_lock_init(&pm->lock);
 
-	setup_timer(&pm->stay_awake, cw1200_pm_stay_awake_tmo,
-		    (unsigned long)pm);
+	timer_setup(&pm->stay_awake, cw1200_pm_stay_awake_tmo, 0);
 
 	return 0;
 }
-- 
2.7.4


-- 
Kees Cook
Pixel Security
