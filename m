From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [patch net-next 1/3] move skb_nfct_reasm into skbuff.h
Date: Tue, 05 Nov 2013 09:50:17 -0200
Message-ID: <5278DB79.2080804@redhat.com>
References: <1383649333-6321-1-git-send-email-jiri@resnulli.us> <1383649333-6321-2-git-send-email-jiri@resnulli.us>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, wensong@linux-vs.org, horms@verge.net.au,
	ja@ssi.bg, edumazet@google.com, pshelar@nicira.com,
	jasowang@redhat.com, alexander.h.duyck@intel.com,
	coreteam@netfilter.org, fw@strlen.de
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1383649333-6321-2-git-send-email-jiri@resnulli.us>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em 05-11-2013 09:02, Jiri Pirko escreveu:
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>

> ---
>   include/linux/skbuff.h          | 11 +++++++++++
>   include/net/ip_vs.h             |  8 --------
>   net/netfilter/ipvs/ip_vs_core.c |  1 +
>   3 files changed, 12 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 2e153b6..ececdad 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2606,6 +2606,17 @@ static inline void nf_conntrack_put_reasm(struct sk_buff *skb)
>   		kfree_skb(skb);
>   }
>   #endif
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
>   #ifdef CONFIG_BRIDGE_NETFILTER
>   static inline void nf_bridge_put(struct nf_bridge_info *nf_bridge)
>   {
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index cd7275f..6dff2b6 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -119,10 +119,6 @@ struct ip_vs_iphdr {
>
>   /* Dependency to module: nf_defrag_ipv6 */
>   #if defined(CONFIG_NF_DEFRAG_IPV6) || defined(CONFIG_NF_DEFRAG_IPV6_MODULE)
> -static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb)
> -{
> -	return skb->nfct_reasm;
> -}
>   static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
>   				      int len, void *buffer,
>   				      const struct ip_vs_iphdr *ipvsh)
> @@ -134,10 +130,6 @@ static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
>   	return skb_header_pointer(skb, offset, len, buffer);
>   }
>   #else
> -static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb)
> -{
> -	return NULL;
> -}
>   static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
>   				      int len, void *buffer,
>   				      const struct ip_vs_iphdr *ipvsh)
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 34fda62..085c242 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -43,6 +43,7 @@
>   #include <net/ip6_checksum.h>
>   #include <net/netns/generic.h>		/* net_generic() */
>
> +#include <linux/skbuff.h>
>   #include <linux/netfilter.h>
>   #include <linux/netfilter_ipv4.h>
>
>

