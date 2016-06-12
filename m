From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net v2] ipv6: fix checksum annotation in udp6_csum_init
Date: Sat, 11 Jun 2016 18:07:29 -0700
Message-ID: <CAM_iQpWJNCE44ZhqWedzpK36yCmvJJx_o9Eg9HYs42=7y+-41w@mail.gmail.com>
References: <1465671401-6329-1-git-send-email-hannes@stressinduktion.org> <1465672537-26131-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:36586 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbcFLBHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 21:07:50 -0400
Received: by mail-yw0-f195.google.com with SMTP id w195so1902740ywd.3
        for <netdev@vger.kernel.org>; Sat, 11 Jun 2016 18:07:49 -0700 (PDT)
In-Reply-To: <1465672537-26131-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 11, 2016 at 12:15 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Cc: Tom Herbert <tom@herbertland.com>
> Fixes: 4068579e1e098fa ("net: Implmement RFC 6936 (zero RX csums for UDP/IPv6")
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/ip6_checksum.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
> index b2025bf3da4af2..c0cbcb259f5a9a 100644
> --- a/net/ipv6/ip6_checksum.c
> +++ b/net/ipv6/ip6_checksum.c
> @@ -78,9 +78,12 @@ int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto)
>          * we accept a checksum of zero here. When we find the socket
>          * for the UDP packet we'll check if that socket allows zero checksum
>          * for IPv6 (set by socket option).
> +        *
> +        * Note, we are only interested in != 0 or == 0, thus the
> +        * force to int.
>          */
> -       return skb_checksum_init_zero_check(skb, proto, uh->check,
> -                                          ip6_compute_pseudo);
> +       return (__force int)skb_checksum_init_zero_check(skb, proto, uh->check,
> +                                                        ip6_compute_pseudo);

Same for udp4_csum_init() ?
