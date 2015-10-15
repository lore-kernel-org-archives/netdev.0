From: Michal Marek <mmarek@suse.com>
Subject: [PATCH 9/9] treewide: Remove newlines inside DEFINE_PER_CPU() macros
Date: Thu, 15 Oct 2015 22:16:35 +0200
Message-ID: <1444940195-28272-10-git-send-email-mmarek@suse.com>
References: <1444940195-28272-1-git-send-email-mmarek@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
	xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org
To: linux-kbuild@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444940195-28272-1-git-send-email-mmarek@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Otherwise make tags can't parse them:

ctags: Warning: arch/ia64/kernel/smp.c:60: null expansion of name pattern "\1"
ctags: Warning: drivers/xen/events/events_2l.c:41: null expansion of name pattern "\1"
ctags: Warning: drivers/acpi/processor_idle.c:64: null expansion of name pattern "\1"
ctags: Warning: kernel/locking/lockdep.c:153: null expansion of name pattern "\1"
ctags: Warning: kernel/workqueue.c:305: null expansion of name pattern "\1"
ctags: Warning: kernel/rcu/rcutorture.c:133: null expansion of name pattern "\1"
ctags: Warning: kernel/rcu/rcutorture.c:135: null expansion of name pattern "\1"
ctags: Warning: net/rds/page.c:45: null expansion of name pattern "\1"
ctags: Warning: net/ipv4/syncookies.c:53: null expansion of name pattern "\1"
ctags: Warning: net/ipv6/syncookies.c:44: null expansion of name pattern "\1"

Cc: linux-ia64@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
Cc: linux-acpi@vger.kernel.org
Cc: rds-devel@oss.oracle.com
Cc: netdev@vger.kernel.org
Signed-off-by: Michal Marek <mmarek@suse.com>
---
 arch/ia64/kernel/smp.c         | 3 +--
 drivers/acpi/processor_idle.c  | 3 +--
 drivers/xen/events/events_2l.c | 3 +--
 kernel/locking/lockdep.c       | 3 +--
 kernel/rcu/rcutorture.c        | 6 ++----
 kernel/workqueue.c             | 3 +--
 net/ipv4/syncookies.c          | 3 +--
 net/ipv6/syncookies.c          | 3 +--
 net/rds/page.c                 | 3 +--
 9 files changed, 10 insertions(+), 20 deletions(-)

diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 7f706d4f84f7..1dcfe29d8a42 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -57,8 +57,7 @@ static struct local_tlb_flush_counts {
 	unsigned int count;
 } __attribute__((__aligned__(32))) local_tlb_flush_counts[NR_CPUS];
 
-static DEFINE_PER_CPU_SHARED_ALIGNED(unsigned short [NR_CPUS],
-				     shadow_flush_counts);
+static DEFINE_PER_CPU_SHARED_ALIGNED(unsigned short [NR_CPUS], shadow_flush_counts);
 
 #define IPI_CALL_FUNC		0
 #define IPI_CPU_STOP		1
diff --git a/drivers/acpi/processor_idle.c b/drivers/acpi/processor_idle.c
index 175c86bee3a9..16ca18547370 100644
--- a/drivers/acpi/processor_idle.c
+++ b/drivers/acpi/processor_idle.c
@@ -61,8 +61,7 @@ module_param(latency_factor, uint, 0644);
 
 static DEFINE_PER_CPU(struct cpuidle_device *, acpi_cpuidle_device);
 
-static DEFINE_PER_CPU(struct acpi_processor_cx * [CPUIDLE_STATE_MAX],
-								acpi_cstate);
+static DEFINE_PER_CPU(struct acpi_processor_cx * [CPUIDLE_STATE_MAX], acpi_cstate);
 
 static int disabled_by_idle_boot_param(void)
 {
diff --git a/drivers/xen/events/events_2l.c b/drivers/xen/events/events_2l.c
index 7dd46312c180..7ffed4c62434 100644
--- a/drivers/xen/events/events_2l.c
+++ b/drivers/xen/events/events_2l.c
@@ -38,8 +38,7 @@
 /* Find the first set bit in a evtchn mask */
 #define EVTCHN_FIRST_BIT(w) find_first_bit(BM(&(w)), BITS_PER_EVTCHN_WORD)
 
-static DEFINE_PER_CPU(xen_ulong_t [EVTCHN_2L_NR_CHANNELS/BITS_PER_EVTCHN_WORD],
-		      cpu_evtchn_mask);
+static DEFINE_PER_CPU(xen_ulong_t [EVTCHN_2L_NR_CHANNELS/BITS_PER_EVTCHN_WORD], cpu_evtchn_mask);
 
 static unsigned evtchn_2l_max_channels(void)
 {
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 8acfbf773e06..3b44d89faa48 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -150,8 +150,7 @@ static inline struct lock_class *hlock_class(struct held_lock *hlock)
 }
 
 #ifdef CONFIG_LOCK_STAT
-static DEFINE_PER_CPU(struct lock_class_stats[MAX_LOCKDEP_KEYS],
-		      cpu_lock_stats);
+static DEFINE_PER_CPU(struct lock_class_stats[MAX_LOCKDEP_KEYS], cpu_lock_stats);
 
 static inline u64 lockstat_clock(void)
 {
diff --git a/kernel/rcu/rcutorture.c b/kernel/rcu/rcutorture.c
index 77192953dee5..588bc3374602 100644
--- a/kernel/rcu/rcutorture.c
+++ b/kernel/rcu/rcutorture.c
@@ -130,10 +130,8 @@ static struct rcu_torture __rcu *rcu_torture_current;
 static unsigned long rcu_torture_current_version;
 static struct rcu_torture rcu_tortures[10 * RCU_TORTURE_PIPE_LEN];
 static DEFINE_SPINLOCK(rcu_torture_lock);
-static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1],
-		      rcu_torture_count) = { 0 };
-static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1],
-		      rcu_torture_batch) = { 0 };
+static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1], rcu_torture_count) = { 0 };
+static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1], rcu_torture_batch) = { 0 };
 static atomic_t rcu_torture_wcount[RCU_TORTURE_PIPE_LEN + 1];
 static atomic_t n_rcu_torture_alloc;
 static atomic_t n_rcu_torture_alloc_fail;
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index ca71582fcfab..b800c945e10b 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -302,8 +302,7 @@ static bool workqueue_freezing;		/* PL: have wqs started freezing? */
 static cpumask_var_t wq_unbound_cpumask; /* PL: low level cpumask for all unbound wqs */
 
 /* the per-cpu worker pools */
-static DEFINE_PER_CPU_SHARED_ALIGNED(struct worker_pool [NR_STD_WORKER_POOLS],
-				     cpu_worker_pools);
+static DEFINE_PER_CPU_SHARED_ALIGNED(struct worker_pool [NR_STD_WORKER_POOLS], cpu_worker_pools);
 
 static DEFINE_IDR(worker_pool_idr);	/* PR: idr of all pools */
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index d70b1f603692..07a5fb157798 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -50,8 +50,7 @@ static u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS] __read_mostly;
 #define TSBITS	6
 #define TSMASK	(((__u32)1 << TSBITS) - 1)
 
-static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS],
-		      ipv4_cookie_scratch);
+static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS], ipv4_cookie_scratch);
 
 static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
 		       u32 count, int c)
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 0909f4e0d53c..5e3ee6a64127 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -41,8 +41,7 @@ static __u16 const msstab[] = {
 	9000 - 60,
 };
 
-static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS],
-		      ipv6_cookie_scratch);
+static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS], ipv6_cookie_scratch);
 
 static u32 cookie_hash(const struct in6_addr *saddr, const struct in6_addr *daddr,
 		       __be16 sport, __be16 dport, u32 count, int c)
diff --git a/net/rds/page.c b/net/rds/page.c
index 9005a2c920ee..6bfb9a59ea55 100644
--- a/net/rds/page.c
+++ b/net/rds/page.c
@@ -42,8 +42,7 @@ struct rds_page_remainder {
 	unsigned long	r_offset;
 };
 
-static DEFINE_PER_CPU_SHARED_ALIGNED(struct rds_page_remainder,
-				     rds_page_remainders);
+static DEFINE_PER_CPU_SHARED_ALIGNED(struct rds_page_remainder, rds_page_remainders);
 
 /*
  * returns 0 on success or -errno on failure.
-- 
2.1.4
