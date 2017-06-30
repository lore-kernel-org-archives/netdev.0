From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC 23/26] sh: Remove spin_unlock_wait() arch-specific definitions
Date: Thu, 29 Jun 2017 17:01:31 -0700
Message-ID: <1498780894-8253-23-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        oleg@redhat.com, akpm@linux-foundation.org, mingo@redhat.com,
        dave@stgolabs.net, manfred@colorfullife.com, tj@kernel.org,
        arnd@arndb.de, linux-arch@vger.kernel.org, will.deacon@arm.com,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>, <linux-sh@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20170629235918.GA6445@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no agreed-upon definition of spin_unlock_wait()'s semantics,
and it appears that all callers could do just as well with a lock/unlock
pair.  This commit therefore removes the underlying arch-specific
arch_spin_unlock_wait().

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>
Cc: <linux-sh@vger.kernel.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andrea Parri <parri.andrea@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 arch/sh/include/asm/spinlock-cas.h  | 5 -----
 arch/sh/include/asm/spinlock-llsc.h | 5 -----
 2 files changed, 10 deletions(-)

diff --git a/arch/sh/include/asm/spinlock-cas.h b/arch/sh/include/asm/spinlock-cas.h
index c46e8cc7b515..5ed7dbbd94ff 100644
--- a/arch/sh/include/asm/spinlock-cas.h
+++ b/arch/sh/include/asm/spinlock-cas.h
@@ -29,11 +29,6 @@ static inline unsigned __sl_cas(volatile unsigned *p, unsigned old, unsigned new
 #define arch_spin_is_locked(x)		((x)->lock <= 0)
 #define arch_spin_lock_flags(lock, flags) arch_spin_lock(lock)
 
-static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
-{
-	smp_cond_load_acquire(&lock->lock, VAL > 0);
-}
-
 static inline void arch_spin_lock(arch_spinlock_t *lock)
 {
 	while (!__sl_cas(&lock->lock, 1, 0));
diff --git a/arch/sh/include/asm/spinlock-llsc.h b/arch/sh/include/asm/spinlock-llsc.h
index cec78143fa83..f77263aae760 100644
--- a/arch/sh/include/asm/spinlock-llsc.h
+++ b/arch/sh/include/asm/spinlock-llsc.h
@@ -21,11 +21,6 @@
 #define arch_spin_is_locked(x)		((x)->lock <= 0)
 #define arch_spin_lock_flags(lock, flags) arch_spin_lock(lock)
 
-static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
-{
-	smp_cond_load_acquire(&lock->lock, VAL > 0);
-}
-
 /*
  * Simple spin lock operations.  There are two variants, one clears IRQ's
  * on the local processor, one does not.
-- 
2.5.2
