From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC 10/26] arc: Remove spin_unlock_wait() arch-specific
 definitions
Date: Thu, 29 Jun 2017 17:01:18 -0700
Message-ID: <1498780894-8253-10-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arch@vger.kernel.org, parri.andrea@gmail.com,
 linux-snps-arc@lists.infradead.org, dave@stgolabs.net,
 manfred@colorfullife.com, arnd@arndb.de, peterz@infradead.org,
 netdev@vger.kernel.org, will.deacon@arm.com, oleg@redhat.com, mingo@redhat.com,
 netfilter-devel@vger.kernel.org, Vineet Gupta <vgupta@synopsys.com>,
 tj@kernel.org, stern@rowland.harvard.edu, akpm@linux-foundation.org,
 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170629235918.GA6445@linux.vnet.ibm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-snps-arc/>
List-Post: <mailto:linux-snps-arc@lists.infradead.org>
List-Help: <mailto:linux-snps-arc-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=subscribe>
Sender: "linux-snps-arc" <linux-snps-arc-bounces@lists.infradead.org>
Errors-To: linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

There is no agreed-upon definition of spin_unlock_wait()'s semantics,
and it appears that all callers could do just as well with a lock/unlock
pair.  This commit therefore removes the underlying arch-specific
arch_spin_unlock_wait().

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: <linux-snps-arc@lists.infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andrea Parri <parri.andrea@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 arch/arc/include/asm/spinlock.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/arch/arc/include/asm/spinlock.h b/arch/arc/include/asm/spinlock.h
index 233d5ffe6ec7..a325e6a36523 100644
--- a/arch/arc/include/asm/spinlock.h
+++ b/arch/arc/include/asm/spinlock.h
@@ -16,11 +16,6 @@
 #define arch_spin_is_locked(x)	((x)->slock != __ARCH_SPIN_LOCK_UNLOCKED__)
 #define arch_spin_lock_flags(lock, flags)	arch_spin_lock(lock)
 
-static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
-{
-	smp_cond_load_acquire(&lock->slock, !VAL);
-}
-
 #ifdef CONFIG_ARC_HAS_LLSC
 
 static inline void arch_spin_lock(arch_spinlock_t *lock)
-- 
2.5.2
