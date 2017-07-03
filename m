From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH RFC 08/26] locking: Remove spin_unlock_wait() generic
 definitions
Date: Mon, 3 Jul 2017 18:13:38 +0100
Message-ID: <20170703171338.GG1573@arm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <1498780894-8253-8-git-send-email-paulmck@linux.vnet.ibm.com>
 <20170630091928.GC9726@arm.com>
 <20170630123815.GT2393@linux.vnet.ibm.com>
 <20170630131339.GA14118@arm.com>
 <20170630221840.GI2393@linux.vnet.ibm.com>
 <20170703131514.GE1573@arm.com>
 <20170703161851.GY2393@linux.vnet.ibm.com>
 <CA+55aFzA+dk8P-wWFX_rYE09A-3uCL8_7ZNG4jC1+c0x4COQkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        NetFilter <netfilter-devel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Oleg Nesterov <oleg@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Manfred Spraul <manfred@colorfullife.com>,
        Tejun Heo <tj@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Alan Stern <stern@rowland.harvard.edu>,
        Andrea Parri <parri.andrea@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFzA+dk8P-wWFX_rYE09A-3uCL8_7ZNG4jC1+c0x4COQkQ@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 03, 2017 at 09:40:22AM -0700, Linus Torvalds wrote:
> On Mon, Jul 3, 2017 at 9:18 AM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> >
> > Agreed, and my next step is to look at spin_lock() followed by
> > spin_is_locked(), not necessarily the same lock.
> 
> Hmm. Most (all?) "spin_is_locked()" really should be about the same
> thread that took the lock (ie it's about asserts and lock debugging).
> 
> The optimistic ABBA avoidance pattern for spinlocks *should* be
> 
>     spin_lock(inner)
>     ...
>     if (!try_lock(outer)) {
>            spin_unlock(inner);
>            .. do them in the right order ..
> 
> so I don't think spin_is_locked() should have any memory barriers.
> 
> In fact, the core function for spin_is_locked() is arguably
> arch_spin_value_unlocked() which doesn't even do the access itself.

Yeah, but there's some spaced-out stuff going on in kgdb_cpu_enter where
it looks to me like raw_spin_is_locked is used for synchronization. My
eyes are hurting looking at it, though.

Will
