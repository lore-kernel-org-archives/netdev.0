From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: minor: tcp: use tcp_skb_mss helper in
 tcp_tso_segment
Date: Thu, 06 Jun 2013 18:20:43 -0700
Message-ID: <1370568043.24311.406.camel@edumazet-glaptop>
References: <1370563643-19556-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:41250 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752944Ab3FGBUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jun 2013 21:20:47 -0400
Received: by mail-pd0-f175.google.com with SMTP id 4so4091654pdd.6
        for <netdev@vger.kernel.org>; Thu, 06 Jun 2013 18:20:47 -0700 (PDT)
In-Reply-To: <1370563643-19556-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-07 at 02:07 +0200, Daniel Borkmann wrote:
> We have the minimal inline helper tcp_skb_mss to access
> skb_shinfo(skb)->gso_size, so also use it here to get mss.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  net/ipv4/tcp.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index b5d4ad9..6a1cf95 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2905,7 +2905,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
>  	oldlen = (u16)~skb->len;
>  	__skb_pull(skb, thlen);
>  
> -	mss = skb_shinfo(skb)->gso_size;
> +	mss = tcp_skb_mss(skb);

Conceptually, this is part of the GRO/GSO layer.

It would be nice to move this stuff in net/ipv4/tcp_offload.c
to makes things explicit.
