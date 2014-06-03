From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 net-next] MPLS: Use mpls_features to
 activate software MPLS GSO segmentation
Date: Mon, 02 Jun 2014 20:42:02 -0700
Message-ID: <1401766922.3645.195.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401684215-14713-1-git-send-email-horms@verge.net.au>
 <20140602162145.GA3836@casper.infradead.org>
 <20140603001640.GA31821@verge.net.au>
 <CAEP_g=8T6kzvQrxQ8f9B9QKiTJq0t3-Eu26c2hycfHTfZNyJbg@mail.gmail.com>
 <20140603023852.GA20728@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140603023852.GA20728-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi Simon

On Tue, 2014-06-03 at 11:38 +0900, Simon Horman wrote:
> +/* If MPLS offload request, verify we are testing hardware MPLS features
> + * instead of standard features for the netdev.
> + */
> +#ifdef CONFIG_NET_MPLS_GSO
> +static netdev_features_t net_mpls_features(struct sk_buff *skb,
> +					   netdev_features_t features)
> +{
> +	int tmp;
> +	__be16 type;
> +
> +	type = skb_network_protocol(skb, &tmp);
> +	if (unlikely(type == cpu_to_be16(ETH_P_MPLS_UC) ||
> +		     type == cpu_to_be16(ETH_P_MPLS_MC)))

I believe net/core/dev.c prefers to use htons(ETH_P_MPLS_UC)

(check netif_skb_features())

> +		features &= skb->dev->mpls_features;
> +
> +	return features;
> +}
> +#else
> +static netdev_features_t net_mpls_features(struct sk_buff *skb,
> +					   netdev_features_t features)
> +{
> +	return features;
> +}
> +#endif
> +
>  static netdev_features_t harmonize_features(struct sk_buff *skb,
>  	netdev_features_t features)
>  {
>  	int tmp;

	_be16 type;

	type = skb_network_protocol(skb, &tmp);

>  
> +	features = net_mpls_features(skb, features);

	features = net_mpls_features(skb, features, type);

> +
>  	if (skb->ip_summed != CHECKSUM_NONE &&
>  	    !can_checksum_protocol(features, skb_network_protocol(skb, &tmp))) {

	!can_checksum_protocol(features, type)) {

>  		features &= ~NETIF_F_ALL_CSUM;



I guess CONFIG_NET_MPLS_GSO will be set by all distros, right ?
