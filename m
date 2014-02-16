From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] netfilter: ipset: move registration message to init from
 net_init
Date: Sun, 16 Feb 2014 11:21:28 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1402161119450.26733@blackhole.kfki.hu>
References: <1392537700-7002-1-git-send-email-imirkin@alum.mit.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: Ilia Mirkin <imirkin@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-in.kfki.hu ([148.6.0.28]:49016 "EHLO smtp2.kfki.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751141AbaBPKVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Feb 2014 05:21:32 -0500
In-Reply-To: <1392537700-7002-1-git-send-email-imirkin@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Feb 2014, Ilia Mirkin wrote:

> Commit 1785e8f473 ("netfiler: ipset: Add net namespace for ipset") moved
> the initialization print into net_init, which can get called a lot due
> to namespaces. Move it back into init, reduce to pr_info.
> 
> Signed-off-by: Ilia Mirkin <imirkin@alum.mit.edu>

I applied your patch in the ipset git tree and will submit the usual way 
for kernel inclusion. Thanks!

Best regards,
Jozsef
 
> The description is based on my meager understanding of what's going on. Feel
> free to adjust it to match reality.
> 
>  net/netfilter/ipset/ip_set_core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
> index bac7e01..0fa2d9c 100644
> --- a/net/netfilter/ipset/ip_set_core.c
> +++ b/net/netfilter/ipset/ip_set_core.c
> @@ -1973,7 +1973,6 @@ ip_set_net_init(struct net *net)
>  		return -ENOMEM;
>  	inst->is_deleted = 0;
>  	rcu_assign_pointer(inst->ip_set_list, list);
> -	pr_notice("ip_set: protocol %u\n", IPSET_PROTOCOL);
>  	return 0;
>  }
>  
> @@ -2024,6 +2023,7 @@ ip_set_init(void)
>  		nfnetlink_subsys_unregister(&ip_set_netlink_subsys);
>  		return ret;
>  	}
> +	pr_info("ip_set: protocol %u\n", IPSET_PROTOCOL);
>  	return 0;
>  }


-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
