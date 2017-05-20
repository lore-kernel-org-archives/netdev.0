From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next] geneve: always fill CSUM6_RX configuration
Date: Fri, 19 May 2017 18:57:46 -0700
Message-ID: <CAOrHB_CKLgriV3XjG1fBHvyB9GQQ3GXOT8+ggmtLXFz3cvj56Q@mail.gmail.com>
References: <20170518195956.12686-1-e@erig.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Garver <e@erig.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay8-d.mail.gandi.net ([217.70.183.201]:35644 "EHLO
        relay8-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755922AbdETB5u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 21:57:50 -0400
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net [217.70.183.197])
        by relay8-d.mail.gandi.net (Postfix) with ESMTPS id D997340496
        for <netdev@vger.kernel.org>; Sat, 20 May 2017 03:57:48 +0200 (CEST)
Received: from mfilter17-d.gandi.net (mfilter17-d.gandi.net [217.70.178.145])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id C418241C07D
        for <netdev@vger.kernel.org>; Sat, 20 May 2017 03:57:48 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter17-d.gandi.net (mfilter17-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id Rq_V9LldDdW2 for <netdev@vger.kernel.org>;
        Sat, 20 May 2017 03:57:47 +0200 (CEST)
Received: from mail-wr0-f181.google.com (mail-wr0-f181.google.com [209.85.128.181])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 5DAA341C07C
        for <netdev@vger.kernel.org>; Sat, 20 May 2017 03:57:47 +0200 (CEST)
Received: by mail-wr0-f181.google.com with SMTP id z52so24951934wrc.2
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 18:57:47 -0700 (PDT)
In-Reply-To: <20170518195956.12686-1-e@erig.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 18, 2017 at 12:59 PM, Eric Garver <e@erig.me> wrote:
> CSMU6_RX is relevant for collect_metadata as well. As such leave it
> outside of the dev's IPv4/IPv6 checks.
>
Can you explain it bit? is this flag used with ipv4 tunnels?

> Fixes: 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
> Signed-off-by: Eric Garver <e@erig.me>
> ---
>  drivers/net/geneve.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index dec5d563ab19..f557d1dc3f9b 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -1311,13 +1311,13 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
>                 if (nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_TX,
>                                !(info->key.tun_flags & TUNNEL_CSUM)))
>                         goto nla_put_failure;
> -
> -               if (nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_RX,
> -                              !geneve->use_udp6_rx_checksums))
> -                       goto nla_put_failure;
>  #endif
>         }
>
> +       if (nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_RX,
> +                      !geneve->use_udp6_rx_checksums))
> +               goto nla_put_failure;
> +
>         if (nla_put_u8(skb, IFLA_GENEVE_TTL, info->key.ttl) ||
>             nla_put_u8(skb, IFLA_GENEVE_TOS, info->key.tos) ||
>             nla_put_be32(skb, IFLA_GENEVE_LABEL, info->key.label))
> --
> 2.12.0
>
