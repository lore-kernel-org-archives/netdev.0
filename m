From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH] 2.6.22.6 netfilter: sk_setup_caps in ip_make_route_harder
Date: Wed, 19 Sep 2007 17:00:41 +0200
Message-ID: <46F13999.30700@trash.net>
References: <20070919093648.GA7491@router.lepton.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: lkm <linux-kernel@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: lepton <ytht.net@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761157AbXISPIA@vger.kernel.org>
In-Reply-To: <20070919093648.GA7491@router.lepton.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

lepton wrote:
> Hi,
>   For local src packets, it is better to update sk_route_caps in
>   ip_route_me_harder.


This seems like a good idea to me. But why only for local src
(address) packets? This function can also be used for locally
generated packet that have been (f.i.) NATed to a foreign
address ...


> Signed-off-by: Lepton Wu <ytht.net@gmail.com>
> 
> diff -pru -X linux-2.6.22.6/Documentation/dontdiff linux-2.6.22.6/net/ipv4/netfilter.c linux-2.6.22.6-lepton/net/ipv4/netfilter.c
> --- linux-2.6.22.6/net/ipv4/netfilter.c	2007-09-19 13:19:13.000000000 +0800
> +++ linux-2.6.22.6-lepton/net/ipv4/netfilter.c	2007-09-19 17:10:36.000000000 +0800
> @@ -37,6 +37,10 @@ int ip_route_me_harder(struct sk_buff **
>  		/* Drop old route. */
>  		dst_release((*pskb)->dst);
>  		(*pskb)->dst = &rt->u.dst;
> +		if((*pskb)->sk){
> +			dst_hold((*pskb)->dst);
> +			sk_setup_caps((*pskb)->sk, (*pskb)->dst);
> +		}
>  	} else {
>  		/* non-local src, find valid iif to satisfy
>  		 * rp-filter when calling ip_route_input. */
> 
