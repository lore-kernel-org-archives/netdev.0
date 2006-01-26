From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: [patch 1/4] net: Percpufy frequently used variables -- add percpu_counter_mod_bh
Date: Thu, 26 Jan 2006 10:59:30 -0800
Message-ID: <20060126185930.GC3651@localhost.localdomain>
References: <20060126185649.GB3651@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	shai@scalex86.org, netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964805AbWAZS72@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060126185649.GB3651@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add percpu_counter_mod_bh for using these counters safely from
both softirq and process context.

Signed-off by: Pravin B. Shelar <pravins@calsoftinc.com>
Signed-off by: Ravikiran G Thirumalai <kiran@scalex86.org>
Signed-off by: Shai Fultheim <shai@scalex86.org>

Index: linux-2.6.16-rc1/include/linux/percpu_counter.h
===================================================================
--- linux-2.6.16-rc1.orig/include/linux/percpu_counter.h	2006-01-25 11:53:56.000000000 -0800
+++ linux-2.6.16-rc1/include/linux/percpu_counter.h	2006-01-25 12:09:41.000000000 -0800
@@ -11,6 +11,7 @@
 #include <linux/smp.h>
 #include <linux/threads.h>
 #include <linux/percpu.h>
+#include <linux/interrupt.h>
 
 #ifdef CONFIG_SMP
 
@@ -102,4 +103,11 @@ static inline void percpu_counter_dec(st
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
