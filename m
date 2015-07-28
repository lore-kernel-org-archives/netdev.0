From: Christopher Hall <christopher.s.hall@intel.com>
Subject: [PATCH 2/5] Added functions mapping TSC value to system time
Date: Mon, 27 Jul 2015 17:46:53 -0700
Message-ID: <1438044416-15588-3-git-send-email-christopher.s.hall@intel.com>
References: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christopher Hall <christopher.s.hall@intel.com>
To: john.stultz@linaro.org, tglx@linutronix.de,
	richardcochran@gmail.com, mingo@redhat.com,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com, hpa@zytor.com,
	x86@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* tsc_to_rawmono64
* tsc_to_realtime64
* tsc_to_mono64

These function build on the counter_to_* time translation function
specifically for TSC based system clock

Signed-off-by: Christopher Hall <christopher.s.hall@intel.com>
---
 arch/x86/include/asm/tsc.h |  5 +++++
 arch/x86/kernel/tsc.c      | 18 ++++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/arch/x86/include/asm/tsc.h b/arch/x86/include/asm/tsc.h
index 94605c0..3fdf8b1 100644
--- a/arch/x86/include/asm/tsc.h
+++ b/arch/x86/include/asm/tsc.h
@@ -5,6 +5,7 @@
 #define _ASM_X86_TSC_H
 
 #include <asm/processor.h>
+#include <linux/time64.h>
 
 #define NS_SCALE	10 /* 2^10, carefully chosen */
 #define US_SCALE	32 /* 2^32, arbitralrily chosen */
@@ -52,6 +53,10 @@ extern int check_tsc_unstable(void);
 extern int check_tsc_disabled(void);
 extern unsigned long native_calibrate_tsc(void);
 
+extern int tsc_to_rawmono64(struct timespec64 *rawmono, cycle_t counterval);
+extern int tsc_to_realtime64(struct timespec64 *realtime, cycle_t counterval);
+extern int tsc_to_mono64(struct timespec64 *mono, cycle_t counterval);
+
 extern int tsc_clocksource_reliable;
 
 /*
diff --git a/arch/x86/kernel/tsc.c b/arch/x86/kernel/tsc.c
index 7437b41..a192271 100644
--- a/arch/x86/kernel/tsc.c
+++ b/arch/x86/kernel/tsc.c
@@ -979,6 +979,24 @@ static cycle_t read_tsc(struct clocksource *cs)
 	return (cycle_t)get_cycles();
 }
 
+int tsc_to_rawmono64(struct timespec64 *rawmono, cycle_t counterval)
+{
+	return counter_to_rawmono64(rawmono, counterval, &clocksource_tsc);
+}
+EXPORT_SYMBOL(tsc_to_rawmono64);
+
+int tsc_to_realtime64(struct timespec64 *realtime, cycle_t counterval)
+{
+	return counter_to_realtime64(realtime, counterval, &clocksource_tsc);
+}
+EXPORT_SYMBOL(tsc_to_realtime64);
+
+int tsc_to_mono64(struct timespec64 *mono, cycle_t counterval)
+{
+	return counter_to_mono64(mono, counterval, &clocksource_tsc);
+}
+EXPORT_SYMBOL(tsc_to_mono64);
+
 /*
  * .mask MUST be CLOCKSOURCE_MASK(64). See comment above read_tsc()
  */
-- 
1.9.1
