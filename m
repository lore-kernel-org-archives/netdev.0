From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC 20/26] parisc: Remove spin_unlock_wait() arch-specific definitions
Date: Thu, 29 Jun 2017 17:01:28 -0700
Message-ID: <1498780894-8253-20-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        oleg@redhat.com, akpm@linux-foundation.org, mingo@redhat.com,
        dave@stgolabs.net, manfred@colorfullife.com, tj@kernel.org,
        arnd@arndb.de, linux-arch@vger.kernel.org, will.deacon@arm.com,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        "James E.J. Bottomley" <jejb@parisc-linux.org>,
        Helge Deller <deller@gmx.de>, <linux-parisc@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20170629235918.GA6445@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no agreed-upon definition of spin_unlock_wait()'s semantics,
and it appears that all callers could do just as well with a lock/unlock
pair.  This commit therefore removes the underlying arch-specific
arch_spin_unlock_wait().

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
Cc: <linux-parisc@vger.kernel.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andrea Parri <parri.andrea@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 arch/parisc/include/asm/spinlock.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/arch/parisc/include/asm/spinlock.h b/arch/parisc/include/asm/spinlock.h
index e32936cd7f10..55bfe4affca3 100644
--- a/arch/parisc/include/asm/spinlock.h
+++ b/arch/parisc/include/asm/spinlock.h
@@ -14,13 +14,6 @@ static inline int arch_spin_is_locked(arch_spinlock_t *x)
 
 #define arch_spin_lock(lock) arch_spin_lock_flags(lock, 0)
 
-static inline void arch_spin_unlock_wait(arch_spinlock_t *x)
-{
-	volatile unsigned int *a = __ldcw_align(x);
-
-	smp_cond_load_acquire(a, VAL);
-}
-
 static inline void arch_spin_lock_flags(arch_spinlock_t *x,
 					 unsigned long flags)
 {
-- 
2.5.2

