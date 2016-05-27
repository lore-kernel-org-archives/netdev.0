From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 1/2] timer: Export destroy_hrtimer_on_stack()
Date: Thu, 26 May 2016 17:21:05 -0700
Message-ID: <1464308466-16525-1-git-send-email-linux@roeck-us.net>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:57574 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755324AbcE0AVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 20:21:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hrtimer_init_on_stack() needs a matching call to
destroy_hrtimer_on_stack(), so both need to be exported.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 kernel/time/hrtimer.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/time/hrtimer.c b/kernel/time/hrtimer.c
index 8c7392c4fdbd..e99df0ff1d42 100644
--- a/kernel/time/hrtimer.c
+++ b/kernel/time/hrtimer.c
@@ -425,6 +425,7 @@ void destroy_hrtimer_on_stack(struct hrtimer *timer)
 {
 	debug_object_free(timer, &hrtimer_debug_descr);
 }
+EXPORT_SYMBOL_GPL(destroy_hrtimer_on_stack);
 
 #else
 static inline void debug_hrtimer_init(struct hrtimer *timer) { }
-- 
2.5.0
