From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH v2 net-next] net: cleanup and document skb fclone layout
Date: Wed, 1 Oct 2014 00:38:54 -0700
Message-ID: <CAGK4HS8QNDmDguFtaqEoU7BGjKm46vw+2Lrmhb363gzBvYgE_g@mail.gmail.com>
References: <1411860341.15768.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412022555.30721.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:55824 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbaJAHiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 03:38:55 -0400
Received: by mail-wi0-f173.google.com with SMTP id bs8so985217wib.6
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 00:38:54 -0700 (PDT)
In-Reply-To: <1412022555.30721.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>         case SKB_FCLONE_CLONE:
> -               fclone_ref = (atomic_t *) (skb + 1);
> -               other = skb - 1;
> +               fclones = container_of(skb, struct sk_buff_fclones, skb2);
>
>                 /* The clone portion is available for
>                  * fast-cloning again.
>                  */
>                 skb->fclone = SKB_FCLONE_UNAVAILABLE;
>

It looks like SKB_FCLONE_UNAVAILABLE has overloaded use depending on
whether we are referring to skb allocated from head_cache or from
fclone_cache. In the former case, it means this skb cannot be cloned
i.e.(clone is unavailable) but in latter case, it means clone is free
to be used.
This overleading is confusing as seen in the comment in snippet above.

Should we add  something like SKB_CLONE_FREE for the second case that
indicates that clone is free for use.?  I can send a patch if it makes
sense..

-vijay
