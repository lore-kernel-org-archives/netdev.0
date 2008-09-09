From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 17/33] netns ct: final init_net tweaks
Date: Tue, 09 Sep 2008 09:20:42 +0200
Message-ID: <48C623CA.9060803@trash.net>
References: <48C01046.2070704@trash.net> <1220842990-30500-17-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1220842990-30500-17-git-send-email-adobriyan@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> Add checks for init_net to not create kmem caches twice and so on.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> 
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index b55944e..52d0663 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -1016,7 +1016,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_flush);
>     supposed to kill the mall. */
>  void nf_conntrack_cleanup(struct net *net)
>  {
> -	rcu_assign_pointer(ip_ct_attach, NULL);
> +	if (net_eq(net, &init_net))
> +		rcu_assign_pointer(ip_ct_attach, NULL);

Having multiple of these net_eq checks per function (14 total) is
not a very nice way to do this. How about splitting the code into
a netns and a global part instead?
