From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: do not fire tasklet unless necessary
Date: Thu, 16 Feb 2017 15:13:54 -0800
Message-ID: <1487286833.1311.63.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG9HWiNfGaWF_uB6F0BttPbzc_eSpow_zv7FwiK3GWoYQA@mail.gmail.com>
         <1487165355.1311.2.camel@edumazet-glaptop3.roam.corp.google.com>
         <1487167443.1311.8.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8WHJYQFEsxU39jgpMDFHPkHuDX6VU7vOcd+wqBedonfA@mail.gmail.com>
         <1487260187.1311.53.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG_w2m9p3OQxi9c9=Y-RVKKLyce1b-WjoSvLUVGcWHNwYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>, jackm@mellanox.com
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35553 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933157AbdBPXN4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 18:13:56 -0500
Received: by mail-pf0-f196.google.com with SMTP id 68so2575771pfx.2
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 15:13:56 -0800 (PST)
In-Reply-To: <CALzJLG_w2m9p3OQxi9c9=Y-RVKKLyce1b-WjoSvLUVGcWHNwYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-16 at 23:17 +0200, Saeed Mahameed wrote:

> so i guess you are not busy polling .. and adaptive moderation decided
> to lower down
> rx-usecs for you, and you are looking to improve latency.
> 
> > Interrupt moderation is a latency killer, we want our usec back.
> >
> 
> well, for RX we have adaptive moderation.
> and for TX we have xmit more.
> so interrupt moderation can be good if it is done right.
> 
> do i understand from this that you are against interrupt moderation ?

Absolutely against it. We prefer gro_flush_timeout.

The defaults values in mlx4 never were tuned for 40Gbit.

If you want to be able to reach 40Gbit on a single TCP flow, you want :

ethtool -C ethX rx-frames 16 rx-usecs-high 32

Or disable interrupt mitigation of course.


Interrupt moderation comes for free with NAPI really :

If under stress, number of interrupts will naturally decrease,
so what's the point with hardware _delaying_ an incoming packet
exactly ???

BTW interrupt moderation in mlx4 has at least two bugs.

I will send a patch.


> 
> >>
> >> > I wonder why this very expensive mb() is required, right before exiting
> >> > the interrupt handler.
> >>
> >> to make sure the HW knows we handled Completions up to (ci) consumer
> >> index. so it will generate next irq.
> >
> >
> > So why a mb() is needed exactly ?
> >
> > wmb() seems enough.
> >
> 
> Yes seems right, not sure why it is mb() though, i will have to check
> and get back to you on this.

Thanks.
