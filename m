From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: Re: [PATCH v2 net-next] net: sk_buff rbnode reorg
Date: Tue, 19 Sep 2017 14:33:13 -0400
Message-ID: <CADAM+B2hA8+UC0198k-cPJt6RCsX5hoSc+fB64Ypbv9cqyAKrg@mail.gmail.com>
References: <1505797616.29839.40.camel@edumazet-glaptop3.roam.corp.google.com> <1505823264.29839.54.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Wei Wang <weiwan@google.com>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:35279 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbdISSdy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 14:33:54 -0400
Received: by mail-ua0-f194.google.com with SMTP id g47so148840uad.2
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 11:33:54 -0700 (PDT)
In-Reply-To: <1505823264.29839.54.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 8:14 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> skb->rbnode shares space with skb->next, skb->prev and skb->tstamp
>
> Current uses (TCP receive ofo queue and netem) need to save/restore
> tstamp, while skb->dev is either NULL (TCP) or a constant for a given
> queue (netem).
>
> Since we plan using an RB tree for TCP retransmit queue to speedup SACK
> processing with large BDP, this patch exchanges skb->dev and
> skb->tstamp.
>
> This saves some overhead in both TCP and netem.
>
> v2: removes the swtstamp field from struct tcp_skb_cb
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: Wei Wang <weiwan@google.com>
> Cc: Willem de Bruijn <willemb@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Very nice!
