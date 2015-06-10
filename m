From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH] atm: idt77105: Use setup_timer
Date: Wed, 10 Jun 2015 11:10:05 +0530
Message-ID: <20150610054005.GA12228@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the timer API function setup_timer instead of structure field
assignments to initialize a timer.

A simplified version of the Coccinelle semantic patch that performs
this transformation is as follows:

@change@
expression e1, e2, a;
@@

-init_timer(&e1);
+setup_timer(&e1, a, 0UL);
... when != a = e2
-e1.function = a;

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
 drivers/atm/idt77105.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/atm/idt77105.c b/drivers/atm/idt77105.c
index 909c95b..feb023d 100644
--- a/drivers/atm/idt77105.c
+++ b/drivers/atm/idt77105.c
@@ -306,14 +306,12 @@ static int idt77105_start(struct atm_dev *dev)
 	if (start_timer) {
 		start_timer = 0;
                 
-		init_timer(&stats_timer);
+		setup_timer(&stats_timer, idt77105_stats_timer_func, 0UL);
 		stats_timer.expires = jiffies+IDT77105_STATS_TIMER_PERIOD;
-		stats_timer.function = idt77105_stats_timer_func;
 		add_timer(&stats_timer);
                 
-		init_timer(&restart_timer);
+		setup_timer(&restart_timer, idt77105_restart_timer_func, 0UL);
 		restart_timer.expires = jiffies+IDT77105_RESTART_TIMER_PERIOD;
-		restart_timer.function = idt77105_restart_timer_func;
 		add_timer(&restart_timer);
 	}
 	spin_unlock_irqrestore(&idt77105_priv_lock, flags);
-- 
1.9.1
