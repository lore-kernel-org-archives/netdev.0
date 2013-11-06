From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch net-next 1/3] move skb_nfct_reasm into skbuff.h
Date: Wed, 6 Nov 2013 10:00:42 +0900
Message-ID: <20131106010042.GA30468@verge.net.au>
References: <1383649333-6321-1-git-send-email-jiri@resnulli.us>
 <1383649333-6321-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	ja@ssi.bg, edumazet@google.com, pshelar@nicira.com,
	jasowang@redhat.com, alexander.h.duyck@intel.com,
	coreteam@netfilter.org, fw@strlen.de
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1383649333-6321-2-git-send-email-jiri@resnulli.us>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 05, 2013 at 12:02:11PM +0100, Jiri Pirko wrote:
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  include/linux/skbuff.h          | 11 +++++++++++
>  include/net/ip_vs.h             |  8 --------
>  net/netfilter/ipvs/ip_vs_core.c |  1 +
>  3 files changed, 12 insertions(+), 8 deletions(-)

IPVS portion:

Acked-by: Simon Horman <horms@verge.net.au>


> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 2e153b6..ececdad 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2606,6 +2606,17 @@ static inline void nf_conntrack_put_reasm(struct sk_buff *skb)
>  		kfree_skb(skb);
>  }
>  #endif
> +#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
> +static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb)
> +{
> +	return skb->nfct_reasm;
> +}
> +#else
> +static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb)
> +{
> +	return NULL;
> +}
> +#endif
>  #ifdef CONFIG_BRIDGE_NETFILTER
>  static inline void nf_bridge_put(struct nf_bridge_info *nf_bridge)
>  {
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index cd7275f..6dff2b6 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -119,10 +119,6 @@ struct ip_vs_iphdr {
>  
>  /* Dependency to module: nf_defrag_ipv6 */
>  #if defined(CONFIG_NF_DEFRAG_IPV6) || defined(CONFIG_NF_DEFRAG_IPV6_MODULE)
> -static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb)
> -{
> -	return skb->nfct_reasm;
> -}
>  static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
>  				      int len, void *buffer,
>  				      const struct ip_vs_iphdr *ipvsh)
> @@ -134,10 +130,6 @@ static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
>  	return skb_header_pointer(skb, offset, len, buffer);
>  }
>  #else
> -static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb)
> -{
> -	return NULL;
> -}
>  static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
>  				      int len, void *buffer,
>  				      const struct ip_vs_iphdr *ipvsh)
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 34fda62..085c242 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -43,6 +43,7 @@
>  #include <net/ip6_checksum.h>
>  #include <net/netns/generic.h>		/* net_generic() */
>  
> +#include <linux/skbuff.h>
>  #include <linux/netfilter.h>
>  #include <linux/netfilter_ipv4.h>
>  
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
