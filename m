From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [PATCH] ip_forward: Drop frames with attached skb->sk
Date: Tue, 14 Apr 2015 14:33:32 +0800
Message-ID: <552CB4BC.9000207@windriver.com>
References: <1428990724.6812.8.camel@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <fw@strlen.de>, <eric.dumazet@gmail.com>
To: Sebastian Poehn <sebastian.poehn@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39644 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbbDNGdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 02:33:32 -0400
In-Reply-To: <1428990724.6812.8.camel@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/14/2015 01:52 PM, Sebastian Poehn wrote:
> Initial discussion was:
> [FYI] xfrm: Don't lookup sk_policy for timewait sockets
>
> Forwarded frames should not have a socket attached. Especially
> tw sockets will lead to panics later-on in the stack.
>
> This was observed with TPROXY assigning a tw socket and broken
> policy routing (misconfigured). As a result frame enters
> forwarding path instead of input. We cannot solve this in
> TPROXY as it cannot know that policy routing is broken.
>
> Signed-off-by: Sebastian Poehn <sebastian.poehn@gmail.com>
> ---
> diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
> index 939992c..2fc3b3e 100644
> --- a/net/ipv4/ip_forward.c
> +++ b/net/ipv4/ip_forward.c
> @@ -82,6 +82,10 @@ int ip_forward(struct sk_buff *skb)
>   	if (skb->pkt_type != PACKET_HOST)
>   		goto drop;
>   
> +	/* this should happen neither */
Sorry. "neither" should be "either"?

Zhu Yanjun
> +	if (unlikely(skb->sk))
> +		goto drop;
> +
>   	if (skb_warn_if_lro(skb))
>   		goto drop;
> --
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
