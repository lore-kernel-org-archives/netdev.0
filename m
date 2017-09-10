From: Florian Westphal <fw@strlen.de>
Subject: Re: Division by zero on UP (was: Re: netfilter: nat: use keyed locks)
Date: Sun, 10 Sep 2017 13:21:26 +0200
Message-ID: <20170910112126.GB25977@breakpoint.cc>
References: <CAMuHMdVwp1njkMYo-y8FZHWNWW6wtN2LYVC=9-mbcF-omDaztw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdVwp1njkMYo-y8FZHWNWW6wtN2LYVC=9-mbcF-omDaztw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> >                 srchash = hash_by_src(net,
> >                                       &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
> > -               spin_lock_bh(&nf_nat_lock);
> > +               lock = &nf_nat_locks[srchash % ARRAY_SIZE(nf_nat_locks)];
> > +               spin_lock_bh(lock);
> 
> If no spinlock debugging options (CONFIG_GENERIC_LOCKBREAK,
> CONFIG_DEBUG_SPINLOCK, CONFIG_DEBUG_LOCK_ALLOC) are enabled on a UP platform
> (e.g. m68k defconfig), arch_spinlock_t is an empty struct, and thus
> ARRAY_SIZE(nf_nat_locks)] is zero, leading to:
> 
>     net/netfilter/nf_nat_core.c: In function ‘nf_nat_setup_info’:
>     net/netfilter/nf_nat_core.c:432: warning: division by zero

Gah. Sorry.  This is the 2nd time I add such a bug :(

Can you send a patch?  It should be enough to use CONNTRACK_LOCKS
instead of ARRAY_SIZE(nf_nat_locks) to avoid this problem.

Otherwise I will take care of this next thing monday morning.
