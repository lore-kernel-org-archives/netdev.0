From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] seqlock: get rid of SEQLOCK_UNLOCKED
Date: Tue, 24 May 2011 14:08:08 +0200
Message-ID: <1306238888.3026.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All static seqlock should be initialized with the lockdep friendly
__SEQLOCK_UNLOCKED() macro.

Remove legacy SEQLOCK_UNLOCKED() macro.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: David Miller <davem@davemloft.net>
---
 arch/ia64/kernel/time.c         |    2 +-
 arch/x86/kernel/vsyscall_64.c   |    2 +-
 include/linux/seqlock.h         |    3 ---
 net/ipv4/inet_connection_sock.c |    2 +-
 4 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 04440cc..85118df 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -36,7 +36,7 @@
 static cycle_t itc_get_cycles(struct clocksource *cs);
 
 struct fsyscall_gtod_data_t fsyscall_gtod_data = {
-	.lock = SEQLOCK_UNLOCKED,
+	.lock = __SEQLOCK_UNLOCKED(fsyscall_gtod_data.lock),
 };
 
 struct itc_jitter_data_t itc_jitter_data;
diff --git a/arch/x86/kernel/vsyscall_64.c b/arch/x86/kernel/vsyscall_64.c
index dcbb28c..59be48d 100644
--- a/arch/x86/kernel/vsyscall_64.c
+++ b/arch/x86/kernel/vsyscall_64.c
@@ -59,7 +59,7 @@ int __vgetcpu_mode __section_vgetcpu_mode;
 
 struct vsyscall_gtod_data __vsyscall_gtod_data __section_vsyscall_gtod_data =
 {
-	.lock = SEQLOCK_UNLOCKED,
+	.lock = __SEQLOCK_UNLOCKED(__vsyscall_gtod_data.lock),
 	.sysctl_enabled = 1,
 };
 
diff --git a/include/linux/seqlock.h b/include/linux/seqlock.h
index 06d6964..e981189 100644
--- a/include/linux/seqlock.h
+++ b/include/linux/seqlock.h
@@ -41,9 +41,6 @@ typedef struct {
 #define __SEQLOCK_UNLOCKED(lockname) \
 		 { 0, __SPIN_LOCK_UNLOCKED(lockname) }
 
-#define SEQLOCK_UNLOCKED \
-		 __SEQLOCK_UNLOCKED(old_style_seqlock_init)
-
 #define seqlock_init(x)					\
 	do {						\
 		(x)->sequence = 0;			\
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 61fac4c..c14d88a 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -33,7 +33,7 @@ EXPORT_SYMBOL(inet_csk_timer_bug_msg);
  * This struct holds the first and last local port number.
  */
 struct local_ports sysctl_local_ports __read_mostly = {
-	.lock = SEQLOCK_UNLOCKED,
+	.lock = __SEQLOCK_UNLOCKED(sysctl_local_ports.lock),
 	.range = { 32768, 61000 },
 };
 
