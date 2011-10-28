From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Fri, 28 Oct 2011 03:25:21 +0200
Message-ID: <20111028012521.GF25795@one.firstfloor.org>
References: <1319764761.23112.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1319764761.23112.14.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 28, 2011 at 03:19:21AM +0200, Eric Dumazet wrote:
> In commit 4e60c86bd9e (gcc-4.6: mm: fix unused but set warnings)
> Andi forced VM_BUG_ON(cond) to evaluate cond, even if CONFIG_DEBUG_VM is
> not set :
> 
> #ifdef CONFIG_DEBUG_VM
> #define VM_BUG_ON(cond) BUG_ON(cond)
> #else
> #define VM_BUG_ON(cond) do { (void)(cond); } while (0)
> #endif

Eventually the warnings were disabled in the Makefile.
So it would be reasonable to just revert that patch now, at least
for VM_BUG_ON, if it costs performance.

> 
> So maybe a fix would be to introduce an atomic_read_stable() variant ?
> 
> static inline int atomic_read_stable(const atomic_t *v)
> {
> 	return v->counter;
> }

Seems reasonable too. In fact we usually should have memory barriers
for this anyways which obsolete the volatile.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
