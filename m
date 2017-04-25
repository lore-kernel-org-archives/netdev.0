From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 10/10] tcp: switch rcv_rtt_est and rcvq_space to
 high resolution timestamps
Date: Tue, 25 Apr 2017 13:54:11 -0400
Message-ID: <CADVnQymteJ+44hWiNtCnktooC9VKRf1cEYvOCfgsVmzyH+ES_g@mail.gmail.com>
References: <20170425171541.3417-1-edumazet@google.com> <20170425171541.3417-11-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33914 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1946907AbdDYRyr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:54:47 -0400
Received: by mail-oi0-f45.google.com with SMTP id x184so181982068oia.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:54:47 -0700 (PDT)
In-Reply-To: <20170425171541.3417-11-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 1:15 PM, Eric Dumazet <edumazet@google.com> wrote:
> Some devices or distributions use HZ=100 or HZ=250
>
> TCP receive buffer autotuning has poor behavior caused by this choice.
> Since autotuning happens after 4 ms or 10 ms, short distance flows
> get their receive buffer tuned to a very high value, but after an initial
> period where it was frozen to (too small) initial value.
>
> With tp->tcp_mstamp introduction, we can switch to high resolution
> timestamps almost for free (at the expense of 8 additional bytes per
> TCP structure)
>
> Note that some TCP stacks use usec TCP timestamps where this
> patch makes even more sense : Many TCP flows have < 500 usec RTT.
> Hopefully this finer TS option can be standardized soon.
>
> Tested:
>  HZ=100 kernel
>  ./netperf -H lpaa24 -t TCP_RR -l 1000 -- -r 10000,10000 &
>
>  Peer without patch :
>  lpaa24:~# ss -tmi dst lpaa23
>  ...
>  skmem:(r0,rb8388608,...)
>  rcv_rtt:10 rcv_space:3210000 minrtt:0.017
>
>  Peer with the patch :
>  lpaa23:~# ss -tmi dst lpaa24
>  ...
>  skmem:(r0,rb428800,...)
>  rcv_rtt:0.069 rcv_space:30000 minrtt:0.017
>
> We can see saner RCVBUF, and more precise rcv_rtt information.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
