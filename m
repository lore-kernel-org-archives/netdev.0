From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH v3] netfilter: ipset: Fix sleeping memory allocation in
 atomic context
Date: Fri, 16 Oct 2015 13:58:55 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1510161357380.15639@blackhole.kfki.hu>
References: <1444977628-19323-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, netfilter-devel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	operations@siteground.com
To: Nikolay Borisov <kernel@kyup.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1444977628-19323-1-git-send-email-kernel@kyup.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 16 Oct 2015, Nikolay Borisov wrote:

> Commit 00590fdd5be0 introduced RCU locking in list type and in
> doing so introduced a memory allocation in list_set_add, which 
> is done in an atomic context, due to the fact that ipset rcu 
> list modifications are serialised with a spin lock. The reason 
> why we can't use a mutex is that in addition to modifying the 
> list with ipset commands, it's also being modified when a
> particular ipset rule timeout expires aka garbage collection. 
> This gc is triggered from set_cleanup_entries, which in turn 
> is invoked from a timer thus requiring the lock to be bh-safe. 
> 
> Concretely the following call chain can lead to "sleeping function
> called in atomic context" splat: 
> call_ad -> list_set_uadt -> list_set_uadd -> kzalloc(, GFP_KERNEL).
> And since GFP_KERNEL allows initiating direct reclaim thus
> potentially sleeping in the allocation path.
> 
> To fix the issue change the allocation type to GFP_ATOMIC, to
> correctly reflect that it is occuring in an atomic context.
> 
> Fixes: 00590fdd5be0 ("netfilter: ipset: Introduce RCU locking in list type")
> 
> Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> Signed-off-by: Nikolay Borisov <kernel@kyup.com>
> ---
> 
> Changes since v2:
>  * Massaged the changelog to reflect discussion 
>  on the mailing list
> 
> Changes since v1: 
>  * Added acked-by 
>  * Fixed patch header
> 
>  
> 
>  net/netfilter/ipset/ip_set_list_set.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

The patch is applied in the ipset package tree. Thanks!
 
Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
