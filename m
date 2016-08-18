From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: refine tcp_prune_ofo_queue() to not drop
 all packets
Date: Thu, 18 Aug 2016 15:08:36 -0400
Message-ID: <CADVnQy=OVOL_Ffe7UYkvh2fgcXwLQuz40M=+ZVyX-HqCUzQZhg@mail.gmail.com>
References: <1471468629.29842.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        "C. Stephen Gun" <csg@google.com>, Van Jacobson <vanj@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:33991 "EHLO
        mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753967AbcHSAtE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 20:49:04 -0400
Received: by mail-oi0-f47.google.com with SMTP id l203so44904258oib.1
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 17:49:04 -0700 (PDT)
In-Reply-To: <1471468629.29842.39.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 5:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> From: Eric Dumazet <edumazet@google.com>
>
> Over the years, TCP BDP has increased a lot, and is typically
> in the order of ~10 Mbytes with help of clever Congestion Control
> modules.
>
> In presence of packet losses, TCP stores incoming packets into an out of
> order queue, and number of skbs sitting there waiting for the missing
> packets to be received can match the BDP (~10 Mbytes)
>
> In some cases, TCP needs to make room for incoming skbs, and current
> strategy can simply remove all skbs in the out of order queue as a last
> resort, incurring a huge penalty, both for receiver and sender.
>
> Unfortunately these 'last resort events' are quite frequent, forcing
> sender to send all packets again, stalling the flow and wasting a lot of
> resources.
>
> This patch cleans only a part of the out of order queue in order
> to meet the memory constraints.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: C. Stephen Gun <csg@google.com>
> Cc: Van Jacobson <vanj@google.com>
> ---

Nice.

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
