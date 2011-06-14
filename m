From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: IGMP snooping: set mrouters_only flag for IPv4 traffic properly
Date: Tue, 14 Jun 2011 13:22:12 -0400
Message-ID: <20110614132212.2ac83c6c@s6510.ftrdhcpuser.net>
References: <1307933995.2704.11.camel@nausicaa>
	<1307934163.3550.2.camel@nausicaa>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	Hayato Kakuta <kakuta.hayato@oss.ntt.co.jp>
To: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46464 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214Ab1FNRWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 13:22:10 -0400
In-Reply-To: <1307934163.3550.2.camel@nausicaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Jun 2011 12:02:43 +0900
Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp> wrote:

> Upon reception of a IGMP/IGMPv2 membership report the kernel sets the
> mrouters_only flag in a skb that may be a clone of the original skb, which
> means that sometimes the bridge loses track of membership report packets (cb
> buffers are tied to a specifici skb and not shared) and it ends up forwading
> join requests to the bridge interface.
> 
> This can cause unexpected membership timeouts and intermitent/permanent loss of connectivity as described in RFC 4541 [2.1.1. IGMP Forwarding Rules]:
> 
>     A snooping switch should forward IGMP Membership Reports only to
>     those ports where multicast routers are attached.
>     [...]
>     Sending membership reports to other hosts can result, for IGMPv1
>     and IGMPv2, in unintentionally preventing a host from joining a
>     specific multicast group.
> 
> 
> Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
> Tested-by: Hayato Kakuta <kakuta.hayato@oss.ntt.co.jp>
> ---
> 
> diff -urNp linux-3.0-rc2-orig/net/bridge/br_multicast.c linux-3.0-rc2/net/bridge/br_multicast.c
> --- linux-3.0-rc2-orig/net/bridge/br_multicast.c	2011-06-09 13:34:04.164261031 +0900
> +++ linux-3.0-rc2/net/bridge/br_multicast.c	2011-06-09 20:04:23.473930447 +0900
> @@ -1424,7 +1424,7 @@ static int br_multicast_ipv4_rcv(struct
>  	switch (ih->type) {
>  	case IGMP_HOST_MEMBERSHIP_REPORT:
>  	case IGMPV2_HOST_MEMBERSHIP_REPORT:
> -		BR_INPUT_SKB_CB(skb2)->mrouters_only = 1;
> +		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
>  		err = br_ip4_multicast_add_group(br, port, ih->group);
>  		break;
>  	case IGMPV3_HOST_MEMBERSHIP_REPORT:

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
