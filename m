From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 2/2] netfilter: ip6t_SYNPROXY: fix sending window
 update to client
Date: Mon, 10 Aug 2015 10:06:07 +0200
Message-ID: <20150810080607.GC20899@acer.localdomain>
References: <20150808155746.GC29362@acer.localdomain>
 <1439118856-26484-1-git-send-email-phil@nwl.cc>
 <1439118856-26484-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1439118856-26484-2-git-send-email-phil@nwl.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09.08, Phil Sutter wrote:
> This is the identical fix as "netfilter: ipt_SYNPROXY: fix sending
> window update to client" but for the IPv6 variant which obviously
> suffers from the same issue.

Looks fine to me.

Acked-by: Patrick McHardy <kaber@trash.net>

(Also for the IPv4 version, which for some reason I didn't receive)

> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
> Changes since v1:
> - Adjust for v2 changes of first patch.
> ---
>  net/ipv6/netfilter/ip6t_SYNPROXY.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
> index bcebc24..ebbb754 100644
> --- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
> +++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
> @@ -243,7 +243,8 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
>  
>  	synproxy_build_options(nth, opts);
>  
> -	synproxy_send_tcp(snet, skb, nskb, NULL, 0, niph, nth, tcp_hdr_size);
> +	synproxy_send_tcp(snet, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
> +	                  niph, nth, tcp_hdr_size);
>  }
>  
>  static bool
> -- 
> 2.1.2
> 
