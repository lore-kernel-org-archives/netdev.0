From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH RFC 08/26] locking: Remove spin_unlock_wait() generic definitions
Date: Mon, 3 Jul 2017 09:40:22 -0700
Message-ID: <CA+55aFzA+dk8P-wWFX_rYE09A-3uCL8_7ZNG4jC1+c0x4COQkQ@mail.gmail.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com> <1498780894-8253-8-git-send-email-paulmck@linux.vnet.ibm.com>
 <20170630091928.GC9726@arm.com> <20170630123815.GT2393@linux.vnet.ibm.com>
 <20170630131339.GA14118@arm.com> <20170630221840.GI2393@linux.vnet.ibm.com>
 <20170703131514.GE1573@arm.com> <20170703161851.GY2393@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Will Deacon <will.deacon@arm.com>,
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
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20170703161851.GY2393@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 3, 2017 at 9:18 AM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> Agreed, and my next step is to look at spin_lock() followed by
> spin_is_locked(), not necessarily the same lock.

Hmm. Most (all?) "spin_is_locked()" really should be about the same
thread that took the lock (ie it's about asserts and lock debugging).

The optimistic ABBA avoidance pattern for spinlocks *should* be

    spin_lock(inner)
    ...
    if (!try_lock(outer)) {
           spin_unlock(inner);
           .. do them in the right order ..

so I don't think spin_is_locked() should have any memory barriers.

In fact, the core function for spin_is_locked() is arguably
arch_spin_value_unlocked() which doesn't even do the access itself.

                       Linus
