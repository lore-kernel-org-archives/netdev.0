From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 1/7] timecounter: provide a macro to initialize the cyclecounter mask field.
Date: Fri,  2 Jan 2015 20:22:03 +0100
Message-ID: <6a4b9de9b82ad5160fc2dfcef59cfd54ee194573.1420226266.git.richardcochran@gmail.com>
References: <20141231.183347.862533634176009078.davem@davemloft.net>
Cc: David Miller <davem@davemloft.net>,
	John Stultz <john.stultz@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:32949 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbbABT3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 14:29:40 -0500
Received: by mail-wi0-f170.google.com with SMTP id bs8so1035228wib.1
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 11:29:39 -0800 (PST)
In-Reply-To: <20141231.183347.862533634176009078.davem@davemloft.net>
In-Reply-To: <cover.1420226266.git.richardcochran@gmail.com>
References: <cover.1420226266.git.richardcochran@gmail.com>
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
