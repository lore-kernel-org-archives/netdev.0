From: Christoph Lameter <cl@linux.com>
Subject: [raw v1 2/4] [NET] Use raw_cpu ops for SNMP stats
Date: Mon, 7 Oct 2013 18:31:58 +0000
Message-ID: <0000014194309205-d0af4d2d-a046-4189-b4f0-ffea37374988-000000@email.amazonses.com>
References: <20131007183226.334180014@linux.com>
Cc: akpm@linuxfoundation.org, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Cc: Steven Rostedt <srostedt@redhat.com>
Cc: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SNMP stats are not protected by preemption but by bh handling.
Since protection is provided outside of preemption raw_cpu_ops
need to be used to avoid false positives.

Cc: Eric Dumazet <edumazet@google.com>
CC: netdev@vger.kernel.org
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/net/snmp.h
===================================================================
--- linux.orig/include/net/snmp.h	2013-10-07 09:16:07.595206864 -0500
+++ linux/include/net/snmp.h	2013-10-07 09:16:07.591206909 -0500
@@ -126,7 +126,7 @@ struct linux_xfrm_mib {
 	extern __typeof__(type) __percpu *name[SNMP_ARRAY_SZ]
 
 #define SNMP_INC_STATS_BH(mib, field)	\
-			__this_cpu_inc(mib[0]->mibs[field])
+			raw_cpu_inc(mib[0]->mibs[field])
 
 #define SNMP_INC_STATS_USER(mib, field)	\
 			this_cpu_inc(mib[0]->mibs[field])
@@ -141,7 +141,7 @@ struct linux_xfrm_mib {
 			this_cpu_dec(mib[0]->mibs[field])
 
 #define SNMP_ADD_STATS_BH(mib, field, addend)	\
-			__this_cpu_add(mib[0]->mibs[field], addend)
+			raw_cpu_add(mib[0]->mibs[field], addend)
 
 #define SNMP_ADD_STATS_USER(mib, field, addend)	\
 			this_cpu_add(mib[0]->mibs[field], addend)
