From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] ipv4: ip_forward: perform skb->pkt_type check
 at the beginning
Date: Wed, 12 Feb 2014 18:25:11 +0400
Message-ID: <52FB8447.9080004@cogentembedded.com>
References: <1392192632-24513-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Denis Kirjanov <kda@linux-powerpc.org>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:35255 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751269AbaBLOZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 09:25:14 -0500
Received: by mail-lb0-f176.google.com with SMTP id w7so7028028lbi.21
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 06:25:13 -0800 (PST)
In-Reply-To: <1392192632-24513-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12-02-2014 12:10, Denis Kirjanov wrote:

> Packets which have L2 address different from ours should be
> already filtered before entering into ip_forward().

> Perform that check at the beginning to avoid processing such packets.

> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> ---
>   net/ipv4/ip_forward.c | 7 ++++---
>   1 file changed, 4 insertions(+), 3 deletions(-)

> diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
> index e9f1217..1a07056 100644
> --- a/net/ipv4/ip_forward.c
> +++ b/net/ipv4/ip_forward.c
> @@ -59,6 +59,10 @@ int ip_forward(struct sk_buff *skb)
>   	struct rtable *rt;	/* Route we use */
>   	struct ip_options *opt	= &(IPCB(skb)->opt);
>
> +    /* that should never happen */
> +    if (skb->pkt_type != PACKET_HOST)
> +        goto drop;
> +

    Please indent the code with tabs, not spaces.

>   	if (skb_warn_if_lro(skb))
>   		goto drop;
>
> @@ -68,9 +72,6 @@ int ip_forward(struct sk_buff *skb)
>   	if (IPCB(skb)->opt.router_alert && ip_call_ra_chain(skb))
>   		return NET_RX_SUCCESS;
>
> -	if (skb->pkt_type != PACKET_HOST)
> -		goto drop;
> -

    Like it was here.

WBR, Sergei
