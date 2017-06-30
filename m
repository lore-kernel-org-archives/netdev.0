From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC 24/26] sparc: Remove spin_unlock_wait() arch-specific definitions
Date: Thu, 29 Jun 2017 17:01:32 -0700
Message-ID: <1498780894-8253-24-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        oleg@redhat.com, akpm@linux-foundation.org, mingo@redhat.com,
        dave@stgolabs.net, manfred@colorfullife.com, tj@kernel.org,
        arnd@arndb.de, linux-arch@vger.kernel.org, will.deacon@arm.com,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        <sparclinux@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170629235918.GA6445@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no agreed-upon definition of spin_unlock_wait()'s semantics,
and it appears that all callers could do just as well with a lock/unlock
pair.  This commit therefore removes the underlying arch-specific
arch_spin_unlock_wait().

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: <sparclinux@vger.kernel.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andrea Parri <parri.andrea@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 arch/sparc/include/asm/spinlock_32.h | 5 -----
 arch/sparc/include/asm/spinlock_64.h | 5 -----
 2 files changed, 10 deletions(-)

diff --git a/arch/sparc/include/asm/spinlock_32.h b/arch/sparc/include/asm/spinlock_32.h
index 8011e79f59c9..67345b2dc408 100644
--- a/arch/sparc/include/asm/spinlock_32.h
+++ b/arch/sparc/include/asm/spinlock_32.h
@@ -14,11 +14,6 @@
 
 #define arch_spin_is_locked(lock) (*((volatile unsigned char *)(lock)) != 0)
 
-static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
-{
-	smp_cond_load_acquire(&lock->lock, !VAL);
-}
-
 static inline void arch_spin_lock(arch_spinlock_t *lock)
 {
 	__asm__ __volatile__(
diff --git a/arch/sparc/include/asm/spinlock_64.h b/arch/sparc/include/asm/spinlock_64.h
index 07c9f2e9bf57..923d57f9b79d 100644
--- a/arch/sparc/include/asm/spinlock_64.h
+++ b/arch/sparc/include/asm/spinlock_64.h
@@ -26,11 +26,6 @@
 
 #define arch_spin_is_locked(lp)	((lp)->lock != 0)
 
-static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
-{
-	smp_cond_load_acquire(&lock->lock, !VAL);
-}
-
 static inline void arch_spin_lock(arch_spinlock_t *lock)
 {
 	unsigned long tmp;
-- 
2.5.2
