From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 1/7] timecounter: provide a macro to initialize the cyclecounter mask field.
Date: Thu,  1 Jan 2015 11:39:55 +0100
Message-ID: <1f1bee3e2aa0cc530d006d99a621992a1497a442.1420108214.git.richardcochran@gmail.com>
References: <20141231.183347.862533634176009078.davem@davemloft.net>
Cc: <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:38959 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbbAAKpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 05:45:46 -0500
In-Reply-To: <20141231.183347.862533634176009078.davem@davemloft.net>
In-Reply-To: <cover.1420108214.git.richardcochran@gmail.com>
References: <cover.1420108214.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need for users of the timecounter/cyclecounter code to include
clocksource.h just for a single macro.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 include/linux/timecounter.h |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/timecounter.h b/include/linux/timecounter.h
index 74f4549..4382035 100644
--- a/include/linux/timecounter.h
+++ b/include/linux/timecounter.h
@@ -19,6 +19,9 @@
 
 #include <linux/types.h>
 
+/* simplify initialization of mask field */
+#define CYCLECOUNTER_MASK(bits) (cycle_t)((bits) < 64 ? ((1ULL<<(bits))-1) : -1)
+
 /**
  * struct cyclecounter - hardware abstraction for a free running counter
  *	Provides completely state-free accessors to the underlying hardware.
@@ -29,7 +32,7 @@
  * @read:		returns the current cycle value
  * @mask:		bitmask for two's complement
  *			subtraction of non 64 bit counters,
- *			see CLOCKSOURCE_MASK() helper macro
+ *			see CYCLECOUNTER_MASK() helper macro
  * @mult:		cycle to nanosecond multiplier
  * @shift:		cycle to nanosecond divisor (power of two)
  */
-- 
1.7.10.4
