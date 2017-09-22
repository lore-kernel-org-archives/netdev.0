From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH,v2,net-next 1/2] tun: enable NAPI for TUN/TAP driver
Date: Fri, 22 Sep 2017 10:06:31 -0400
Message-ID: <CAF=yD-KOWL1myXb8xFR30c0Z8MirGwz47fWUGTUoBq1+ubR2WA@mail.gmail.com>
References: <20170922021715.2618-1-peterpenkov96@gmail.com> <20170922021715.2618-2-peterpenkov96@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>, ppenkov@stanford.edu
To: Petar Penkov <peterpenkov96@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:53119 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752429AbdIVOHN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 10:07:13 -0400
Received: by mail-io0-f180.google.com with SMTP id i197so3275757ioe.9
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 07:07:12 -0700 (PDT)
In-Reply-To: <20170922021715.2618-2-peterpenkov96@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 21, 2017 at 10:17 PM, Petar Penkov <peterpenkov96@gmail.com> wrote:
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
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: davem@davemloft.net
> Cc: ppenkov@stanford.edu

Acked-by: Willem de Bruijn <willemb@google.com>

Thanks, Petar.
