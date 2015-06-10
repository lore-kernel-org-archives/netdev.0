From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC net-next 1/3] Symbol preparation for VRF driver
Date: Wed, 10 Jun 2015 09:24:49 -0700
Message-ID: <557864D1.7030509@gmail.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com> <0ab84f044790bce44311838edbcbe9e128cac369.1433561681.git.shm@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	dsahern@gmail.com, ebiederm@xmission.com, hadi@mojatatu.com,
	davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34897 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965190AbbFJQYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 12:24:52 -0400
Received: by pacyx8 with SMTP id yx8so37943643pac.2
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 09:24:51 -0700 (PDT)
In-Reply-To: <0ab84f044790bce44311838edbcbe9e128cac369.1433561681.git.shm@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/08/2015 11:35 AM, Shrijeet Mukherjee wrote:
> From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
>
> This change is needed for the following VRF driver which creates
> a routing domain and allows applications to bind to the domain.
>
> No active code path changes.
>
> Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
> ---
>   net/ipv4/fib_frontend.c |    1 +
>   net/ipv4/fib_trie.c     |    2 ++
>   2 files changed, 3 insertions(+)
>
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 872494e..9d4cef4 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -108,6 +108,7 @@ struct fib_table *fib_new_table(struct net *net, u32 id)
>   	hlist_add_head_rcu(&tb->tb_hlist, &net->ipv4.fib_table_hash[h]);
>   	return tb;
>   }
> +EXPORT_SYMBOL_GPL(fib_new_table);
>
>   /* caller must hold either rtnl or rcu read lock */
>   struct fib_table *fib_get_table(struct net *net, u32 id)

So this block of code is wrapped in a #ifdef for 
CONFIG_IP_MULTIPLE_TABLES so anything that references it will need to 
make sure that it is defined.

> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index 01bce15..97fa62d 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -1247,6 +1247,7 @@ out:
>   err:
>   	return err;
>   }
> +EXPORT_SYMBOL_GPL(fib_table_insert);
>
>   static inline t_key prefix_mismatch(t_key key, struct key_vector *n)
>   {
> @@ -1535,6 +1536,7 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
>   	alias_free_mem_rcu(fa_to_delete);
>   	return 0;
>   }
> +EXPORT_SYMBOL_GPL(fib_table_delete);
>
>   /* Scan for the next leaf starting at the provided key value */
>   static struct key_vector *leaf_walk_rcu(struct key_vector **tn, t_key key)
>
