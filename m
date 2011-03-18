From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 21/36] net,rcu: convert call_rcu(netlbl_unlhsh_free_addr6) to kfree_rcu()
Date: Fri, 18 Mar 2011 16:06:11 -0400
Message-ID: <201103181606.12058.paul.moore@hp.com>
References: <4D82D9E2.4000408@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:25418 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756995Ab1CRUGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 16:06:25 -0400
In-Reply-To: <4D82D9E2.4000408@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, March 18, 2011 12:04:50 AM Lai Jiangshan wrote:
> The rcu callback netlbl_unlhsh_free_addr6() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(netlbl_unlhsh_free_addr6).
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: Paul Moore <paul.moore@hp.com>

> ---
>  net/netlabel/netlabel_unlabeled.c |   22 +---------------------
>  1 files changed, 1 insertions(+), 21 deletions(-)
> 
> diff --git a/net/netlabel/netlabel_unlabeled.c
> b/net/netlabel/netlabel_unlabeled.c index 4e5ad90..9c38658 100644
> --- a/net/netlabel/netlabel_unlabeled.c
> +++ b/net/netlabel/netlabel_unlabeled.c
> @@ -153,26 +153,6 @@ static const struct nla_policy
> netlbl_unlabel_genl_policy[NLBL_UNLABEL_A_MAX + 1 * Unlabeled Connection
> Hash Table Functions
>   */
> 
> -#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> -/**
> - * netlbl_unlhsh_free_addr6 - Frees an IPv6 address entry from the hash
> table - * @entry: the entry's RCU field
> - *
> - * Description:
> - * This function is designed to be used as a callback to the call_rcu()
> - * function so that memory allocated to a hash table address entry can be
> - * released safely.
> - *
> - */
> -static void netlbl_unlhsh_free_addr6(struct rcu_head *entry)
> -{
> -	struct netlbl_unlhsh_addr6 *ptr;
> -
> -	ptr = container_of(entry, struct netlbl_unlhsh_addr6, rcu);
> -	kfree(ptr);
> -}
> -#endif /* IPv6 */
> -
>  /**
>   * netlbl_unlhsh_free_iface - Frees an interface entry from the hash table
>   * @entry: the entry's RCU field
> @@ -611,7 +591,7 @@ static int netlbl_unlhsh_remove_addr6(struct net *net,
>  	if (entry == NULL)
>  		return -ENOENT;
> 
> -	call_rcu(&entry->rcu, netlbl_unlhsh_free_addr6);
> +	kfree_rcu(entry, rcu);
>  	return 0;
>  }
>  #endif /* IPv6 */


--
paul moore
linux @ hp
