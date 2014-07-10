From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [RFC][PATCH] ipv6: fix the check when handle RA
Date: Thu, 10 Jul 2014 11:26:50 +0200
Message-ID: <1404984410.12704.3.camel@localhost>
References: <1404980946-3289-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64785 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005AbaGJJ0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2014 05:26:55 -0400
In-Reply-To: <1404980946-3289-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Do, 2014-07-10 at 16:29 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> d9333196572(ipv6:  Allow accepting RA from local IP addresses.) made
> ndisc_router_discovery to skip to handle RA when accept_ra_from_local
> is 0 and saddr of packet is not the device address, in fact, this
> condition should be handled
> 
> Fixes: d9333196572(ipv6:  Allow accepting RA from local IP addresses.)
> Cc: Ben Greear <greearb@candelatech.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>  net/ipv6/ndisc.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index a845e3d..e70e805 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -1152,8 +1152,8 @@ static void ndisc_router_discovery(struct sk_buff *skb)
>  	 * accept_ra_from_local is set to true.
>  	 */
>  	if (!(in6_dev->cnf.accept_ra_from_local ||
> -	      ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> -			    NULL, 0))) {
> +	      !ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> +			     NULL, 0))) {

Uh!

Instead of double negotiation can you please write

if (!in6_dev->cnf.accept_ra_from_local &&
    ipv6_chk_addr(...)) {
	printk(...);
	goto skip;
}

Thanks for fixing this, good catch!

Thanks,
Hannes
