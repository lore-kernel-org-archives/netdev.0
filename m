From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC 26/26] xtensa: Remove spin_unlock_wait() arch-specific definitions
Date: Thu, 29 Jun 2017 17:01:34 -0700
Message-ID: <1498780894-8253-26-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        oleg@redhat.com, akpm@linux-foundation.org, mingo@redhat.com,
        dave@stgolabs.net, manfred@colorfullife.com, tj@kernel.org,
        arnd@arndb.de, linux-arch@vger.kernel.org, will.deacon@arm.com,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Chris Zankel <chris@zankel.net>,
        Max Filippov <jcmvbkbc@gmail.com>,
        <linux-xtensa@linux-xtensa.org>
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
Cc: Chris Zankel <chris@zankel.net>
Cc: Max Filippov <jcmvbkbc@gmail.com>
Cc: <linux-xtensa@linux-xtensa.org>
---
 arch/xtensa/include/asm/spinlock.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/arch/xtensa/include/asm/spinlock.h b/arch/xtensa/include/asm/spinlock.h
index a36221cf6363..3bb49681ee24 100644
--- a/arch/xtensa/include/asm/spinlock.h
+++ b/arch/xtensa/include/asm/spinlock.h
@@ -33,11 +33,6 @@
 
 #define arch_spin_is_locked(x) ((x)->slock != 0)
 
-static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
-{
-	smp_cond_load_acquire(&lock->slock, !VAL);
-}
-
 #define arch_spin_lock_flags(lock, flags) arch_spin_lock(lock)
 
 static inline void arch_spin_lock(arch_spinlock_t *lock)
-- 
2.5.2
