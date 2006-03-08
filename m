From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: [patch 1/4] net: percpufy frequently used vars -- add percpu_counter_mod_bh
Date: Tue, 7 Mar 2006 17:59:34 -0800
Message-ID: <20060308015934.GB9062@localhost.localdomain>
References: <20060308015808.GA9062@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, shai@scalex86.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964878AbWCHB6y@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060308015808.GA9062@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add percpu_counter_mod_bh for using these counters safely from
both softirq and process context.

Signed-off by: Pravin B. Shelar <pravins@calsoftinc.com>
Signed-off by: Ravikiran G Thirumalai <kiran@scalex86.org>
Signed-off by: Shai Fultheim <shai@scalex86.org>

Index: linux-2.6.16-rc5mm3/include/linux/percpu_counter.h
===================================================================
--- linux-2.6.16-rc5mm3.orig/include/linux/percpu_counter.h	2006-03-07 15:08:00.000000000 -0800
+++ linux-2.6.16-rc5mm3/include/linux/percpu_counter.h	2006-03-07 15:09:21.000000000 -0800
@@ -11,6 +11,7 @@
 #include <linux/smp.h>
 #include <linux/threads.h>
 #include <linux/percpu.h>
+#include <linux/interrupt.h>
 
 #ifdef CONFIG_SMP
 
@@ -110,4 +111,11 @@ static inline void percpu_counter_dec(st
 	percpu_counter_mod(fbc, -1);
 }
 
+static inline void percpu_counter_mod_bh(struct percpu_counter *fbc, long amount)
+{
+	local_bh_disable();
+	percpu_counter_mod(fbc, amount);
+	local_bh_enable();
+}
+
 #endif /* _LINUX_PERCPU_COUNTER_H */
