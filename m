From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] ipv4: fix a potential use after free
Date: Fri, 17 Oct 2014 10:07:37 -0700
Message-ID: <CALnjE+rb33CdoA5Paho4WyX=ED8WCo6G4BaHdQ4u6_N4DMqh9w@mail.gmail.com>
References: <1413536003-15646-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Li RongQing <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:60981 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753127AbaJQRHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 13:07:38 -0400
Received: by mail-ie0-f175.google.com with SMTP id x19so1149933ier.20
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 10:07:37 -0700 (PDT)
In-Reply-To: <1413536003-15646-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 17, 2014 at 1:53 AM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> pskb_may_pull() maybe change skb->data and make eth pointer oboslete,
> so set eth after pskb_may_pull()
>
> Fixes:3d7b46cd("ip_tunnel: push generic protocol handling to ip_tunnel module")
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Looks good.
Acked-by: Pravin B Shelar <pshelar@nicira.com>

> ---
>  net/ipv4/ip_tunnel_core.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
> index f4c987b..88c386c 100644
> --- a/net/ipv4/ip_tunnel_core.c
> +++ b/net/ipv4/ip_tunnel_core.c
> @@ -91,11 +91,12 @@ int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto)
>         skb_pull_rcsum(skb, hdr_len);
>
>         if (inner_proto == htons(ETH_P_TEB)) {
> -               struct ethhdr *eh = (struct ethhdr *)skb->data;
> +               struct ethhdr *eh;
>
>                 if (unlikely(!pskb_may_pull(skb, ETH_HLEN)))
>                         return -ENOMEM;
>
> +               eh = (struct ethhdr *)skb->data;
>                 if (likely(ntohs(eh->h_proto) >= ETH_P_802_3_MIN))
>                         skb->protocol = eh->h_proto;
>                 else
> --
> 1.7.10.4
>
