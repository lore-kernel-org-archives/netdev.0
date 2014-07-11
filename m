From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-next] ipv6: fix the check when handle RA
Date: Fri, 11 Jul 2014 00:20:35 -0700
Message-ID: <53BF9043.20709@candelatech.com>
References: <1404986566-9651-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com
To: roy.qing.li@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:42866 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbaGKHUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 03:20:40 -0400
In-Reply-To: <1404986566-9651-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2014 03:02 AM, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> d9333196572(ipv6:  Allow accepting RA from local IP addresses.) made the wrong
> check, whether or not to accept RA with source-addr found on local machine, when
> accept_ra_from_local is 0.

Thanks for fixing this.  I found the 'ipv6_chk_addr' method's actual
behaviour and name hard to coorelate, and I must have written this part
while confused.

I will apply your patch and test in my scenario once I'm
back from vacation, just to be certain.

Thanks,
Ben

>
> Fixes: d9333196572(ipv6:  Allow accepting RA from local IP addresses.)
> Cc: Ben Greear <greearb@candelatech.com>
> Cc: Hannes Frederic Sowa <hannes@redhat.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>   net/ipv6/ndisc.c |   12 ++++++------
>   1 file changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index a845e3d..139b45f 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -1151,9 +1151,9 @@ static void ndisc_router_discovery(struct sk_buff *skb)
>   	/* Do not accept RA with source-addr found on local machine unless
>   	 * accept_ra_from_local is set to true.
>   	 */
> -	if (!(in6_dev->cnf.accept_ra_from_local ||
> -	      ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> -			    NULL, 0))) {
> +	if (!in6_dev->cnf.accept_ra_from_local &&
> +	    ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> +			  NULL, 0)) {
>   		ND_PRINTK(2, info,
>   			  "RA from local address detected on dev: %s: default router ignored\n",
>   			  skb->dev->name);
> @@ -1294,9 +1294,9 @@ skip_linkparms:
>   	}
>
>   #ifdef CONFIG_IPV6_ROUTE_INFO
> -	if (!(in6_dev->cnf.accept_ra_from_local ||
> -	      ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> -			    NULL, 0))) {
> +	if (!in6_dev->cnf.accept_ra_from_local &&
> +	    ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> +			  NULL, 0)) {
>   		ND_PRINTK(2, info,
>   			  "RA from local address detected on dev: %s: router info ignored.\n",
>   			  skb->dev->name);
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
