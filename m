From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v3 3/3] 6lowpan: remove excessive argument in
 pr_debug
Date: Sat, 09 Jun 2012 12:37:42 -0700
Message-ID: <1339270662.8170.6.camel@joe2Laptop>
References: <1339254789-10712-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	 <1339254789-10712-4-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:45378 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751550Ab2FIThn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2012 15:37:43 -0400
In-Reply-To: <1339254789-10712-4-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-06-09 at 19:13 +0400, Alexander Smirnov wrote:
> Remove excessive __func__ argument in pr_debug function.

Hello Alexander.

trivial comments below:

> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c

> @@ -240,7 +240,7 @@ lowpan_uncompress_addr(struct sk_buff *skb, struct in6_addr *ipaddr,
>  		lowpan_uip_ds6_set_addr_iid(ipaddr, lladdr);
>  	}
>  
> -	pr_debug("(%s): uncompressing %d + %d => ", __func__, prefcount,
> +	pr_debug("uncompressing %d + %d => ", prefcount,
>  								postcount);

It'd be nicer to move the second argument as well.

	pr_debug("uncompressing %d + %d => ", prefcount, postcount);
[]

> @@ -543,7 +541,7 @@ static int lowpan_header_create(struct sk_buff *skb,
>  			hc06_ptr += 16;
>  		}
>  	} else {
> -		pr_debug("(%s): destination address is unicast: ", __func__);
> +		pr_debug("destination address is unicast: ");
>  		/* TODO: context lookup */
>  		if (is_addr_link_local(&hdr->daddr)) {
>  			pr_debug("destination address is link-local\n");

This doesn't really look correct.  Should this be newline terminated?

[]
> @@ -894,14 +890,14 @@ lowpan_process_data(struct sk_buff *skb)
>  	/* check for Multicast Compression */
>  	if (iphc1 & LOWPAN_IPHC_M) {
>  		if (iphc1 & LOWPAN_IPHC_DAC) {
> -			pr_debug("(%s): destination address context-based "
> -				 "multicast compression\n", __func__);
> +			pr_debug("destination address context-based "
> +				 "multicast compression\n");

Please coalesce format strings.

			pr_debug("destination address context-based multicast compression\n");
[]
> +			pr_debug("destination address non-context-based"
> +				 " multicast compression\n");

etc...
