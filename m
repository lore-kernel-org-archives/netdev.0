From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH net-next] net: small skb_segment() cleanup
Date: Fri, 17 May 2013 10:20:04 -0700
Message-ID: <CAHLZz11hoXDQ3ie2jBnfpQG7+SqgCuNMBA087ms3M+OPtnhqKA@mail.gmail.com>
References: <1368810804.3301.100.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f172.google.com ([209.85.220.172]:52547 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755922Ab3EQRUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 13:20:05 -0400
Received: by mail-vc0-f172.google.com with SMTP id hf12so2981455vcb.17
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 10:20:04 -0700 (PDT)
In-Reply-To: <1368810804.3301.100.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 17, 2013 at 10:13 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>


> @@ -2817,7 +2817,6 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
>
>                         nskb->truesize += skb_end_offset(nskb) - hsize;
>                         skb_release_head_state(nskb);
> -                       __skb_push(nskb, doffset);

is __skb_push equivalent to __skb_put?

Harvey

>                 } else {
>                         nskb = __alloc_skb(hsize + doffset + headroom,
>                                            GFP_ATOMIC, skb_alloc_rx_flag(skb),
> @@ -2827,8 +2826,8 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
>                                 goto err;
>
>                         skb_reserve(nskb, headroom);
> -                       __skb_put(nskb, doffset);
>                 }
> +               __skb_put(nskb, doffset);
>
>                 if (segs)
>                         tail->next = nskb;
>
