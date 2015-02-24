From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v4 1/2] igmp v6: add __ipv6_sock_mc_join and
 __ipv6_sock_mc_drop
Date: Tue, 24 Feb 2015 11:15:30 +0100
Message-ID: <54EC4F42.8060702@iogearbox.net>
References: <1424739550-2691-1-git-send-email-challa@noironetworks.com> <1424739550-2691-2-git-send-email-challa@noironetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Madhu Challa <challa@noironetworks.com>, eric.dumazet@gmail.com,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53077 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbbBXKPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 05:15:33 -0500
In-Reply-To: <1424739550-2691-2-git-send-email-challa@noironetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2015 01:59 AM, Madhu Challa wrote:
> Based on the igmp v4 changes from Eric Dumazet.
> 959d10f6bbf6("igmp: add __ip_mc_{join|leave}_group()")
>
> These changes are needed to perform igmp v6 join/leave while
> RTNL is held.
>
> Make ipv6_sock_mc_join and ipv6_sock_mc_drop wrappers around
> __ipv6_sock_mc_join and  __ipv6_sock_mc_drop to avoid
> proliferation of work queues.
>
> Signed-off-by: Madhu Challa <challa@noironetworks.com>
...
> @@ -198,25 +197,38 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
>   	mc_lst->next = np->ipv6_mc_list;
>   	rcu_assign_pointer(np->ipv6_mc_list, mc_lst);
>
> -	rtnl_unlock();
>

Nit: you can also get rid of the newline.

>   	return 0;
>   }
> +EXPORT_SYMBOL(__ipv6_sock_mc_join);
> +
> +int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
> +{

Rest looks good to me.

Thanks,
Daniel
