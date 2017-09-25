From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH,v3,net-next 1/2] tun: enable NAPI for TUN/TAP driver
Date: Mon, 25 Sep 2017 09:23:48 -0700
Message-ID: <CAF2d9ji-aKqmT4Cdcs4E=YtdAe4GP+J5yp-G-x=s9L6D-nn_rA@mail.gmail.com>
References: <20170922204915.7889-1-peterpenkov96@gmail.com> <20170922204915.7889-2-peterpenkov96@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>,
        Petar Bozhidarov Penkov <ppenkov@stanford.edu>
To: Petar Penkov <peterpenkov96@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:44843 "EHLO
        mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752558AbdIYQYK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 12:24:10 -0400
Received: by mail-yw0-f170.google.com with SMTP id r85so5101741ywg.1
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 09:24:10 -0700 (PDT)
In-Reply-To: <20170922204915.7889-2-peterpenkov96@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 22, 2017 at 1:49 PM, Petar Penkov <peterpenkov96@gmail.com> wrote:
> Changes TUN driver to use napi_gro_receive() upon receiving packets
> rather than netif_rx_ni(). Adds flag IFF_NAPI that enables these
> changes and operation is not affected if the flag is disabled.  SKBs
> are constructed upon packet arrival and are queued to be processed
> later.
>
> The new path was evaluated with a benchmark with the following setup:
> Open two tap devices and a receiver thread that reads in a loop for
> each device. Start one sender thread and pin all threads to different
> CPUs. Send 1M minimum UDP packets to each device and measure sending
> time for each of the sending methods:
>         napi_gro_receive():     4.90s
>         netif_rx_ni():          4.90s
>         netif_receive_skb():    7.20s
>
> Signed-off-by: Petar Penkov <peterpenkov96@gmail.com>

Thank you Petar.

Acked-by: Mahesh Bandewar <maheshb@google.com>

> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: davem@davemloft.net
> Cc: ppenkov@stanford.edu
> ---
>  drivers/net/tun.c           | 133 +++++++++++++++++++++++++++++++++++++++-----
>  include/uapi/linux/if_tun.h |   1 +
>  2 files changed, 119 insertions(+), 15 deletions(-)
>
