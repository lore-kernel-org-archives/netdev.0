From: Florian Westphal <fw@strlen.de>
Subject: Re: linux-next: build warnings after merge of the net-next tree
Date: Sat, 20 Jun 2015 19:40:03 +0200
Message-ID: <20150620174003.GD4683@breakpoint.cc>
References: <20150620231255.320ed133@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:33349 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752480AbbFTRkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2015 13:40:11 -0400
Content-Disposition: inline
In-Reply-To: <20150620231255.320ed133@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> After merging the net-next tree, today's linux-next build (i386 defconfig)
> produced these warnings:
> 
> In file included from include/net/netfilter/nf_conntrack_tuple.h:13:0,
>                  from include/linux/netfilter/nf_conntrack_dccp.h:28,
>                  from include/net/netfilter/nf_conntrack.h:22,
>                  from net/netfilter/nf_conntrack_core.c:37:
> include/linux/netfilter/x_tables.h: In function 'xt_percpu_counter_alloc':
> include/linux/netfilter/x_tables.h:373:10: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
>    return (__force u64) res;
>           ^
> include/linux/netfilter/x_tables.h: In function 'xt_percpu_counter_free':
> include/linux/netfilter/x_tables.h:381:15: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
>    free_percpu((void __percpu *) pcnt);
>                ^
> In file included from include/asm-generic/percpu.h:6:0,
>                  from arch/x86/include/asm/percpu.h:551,
>                  from arch/x86/include/asm/preempt.h:5,
>                  from include/linux/preempt.h:64,
>                  from include/linux/spinlock.h:50,
>                  from include/linux/mm_types.h:8,
>                  from include/linux/kmemcheck.h:4,
>                  from include/linux/skbuff.h:18,
>                  from include/linux/netfilter.h:5,
>                  from net/netfilter/nf_conntrack_core.c:16:
> include/linux/netfilter/x_tables.h: In function 'xt_get_this_cpu_counter':
> include/linux/netfilter/x_tables.h:388:23: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
>    return this_cpu_ptr((void __percpu *) cnt->pcnt);
>                        ^
> include/linux/percpu-defs.h:206:47: note: in definition of macro '__verify_pcpu_ptr'
>   const void __percpu *__vpp_verify = (typeof((ptr) + 0))NULL; \
>                                                ^
> include/linux/percpu-defs.h:239:27: note: in expansion of macro 'raw_cpu_ptr'
>  #define this_cpu_ptr(ptr) raw_cpu_ptr(ptr)
>                            ^
> include/linux/netfilter/x_tables.h:388:10: note: in expansion of macro 'this_cpu_ptr'
>    return this_cpu_ptr((void __percpu *) cnt->pcnt);
>           ^
> 
> and many more.
> 
> Introduced by commit:
> 
>   71ae0dff02d7 ("netfilter: xtables: use percpu rule counters")

Yes, sorry about this, should be fixed by dcb8f5c8139ef945cdfd
("netfilter: xtables: fix warnings on 32bit platforms").

Thanks,
Florian
