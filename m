From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 1/3] atm: idt77105: Drop needless setup_timer()
Date: Tue, 10 Oct 2017 12:25:48 -0700
Message-ID: <1507663550-13343-2-git-send-email-keescook@chromium.org>
References: <1507663550-13343-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Chas Williams <3chas3@gmail.com>,
        linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:52386 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753369AbdJJT0A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 15:26:00 -0400
Received: by mail-pf0-f182.google.com with SMTP id a1so15025078pfj.9
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 12:26:00 -0700 (PDT)
In-Reply-To: <1507663550-13343-1-git-send-email-keescook@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling setup_timer() is redundant when DEFINE_TIMER() has been used.

Cc: Chas Williams <3chas3@gmail.com>
Cc: linux-atm-general@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This is intended to go via the timer tree. Acks appreciated!
---
 drivers/atm/idt77105.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/atm/idt77105.c b/drivers/atm/idt77105.c
index 57af9fd198e4..909744eb7bab 100644
--- a/drivers/atm/idt77105.c
+++ b/drivers/atm/idt77105.c
@@ -306,11 +306,9 @@ static int idt77105_start(struct atm_dev *dev)
 	if (start_timer) {
 		start_timer = 0;
                 
-		setup_timer(&stats_timer, idt77105_stats_timer_func, 0UL);
 		stats_timer.expires = jiffies+IDT77105_STATS_TIMER_PERIOD;
 		add_timer(&stats_timer);
                 
-		setup_timer(&restart_timer, idt77105_restart_timer_func, 0UL);
 		restart_timer.expires = jiffies+IDT77105_RESTART_TIMER_PERIOD;
 		add_timer(&restart_timer);
 	}
-- 
2.7.4
