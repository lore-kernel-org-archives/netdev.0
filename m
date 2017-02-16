From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: do not fire tasklet unless necessary
Date: Thu, 16 Feb 2017 07:49:47 -0800
Message-ID: <1487260187.1311.53.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG9HWiNfGaWF_uB6F0BttPbzc_eSpow_zv7FwiK3GWoYQA@mail.gmail.com>
         <1487165355.1311.2.camel@edumazet-glaptop3.roam.corp.google.com>
         <1487167443.1311.8.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8WHJYQFEsxU39jgpMDFHPkHuDX6VU7vOcd+wqBedonfA@mail.gmail.com>
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
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34713 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932482AbdBPPtx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 10:49:53 -0500
Received: by mail-pf0-f193.google.com with SMTP id o64so1894200pfb.1
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 07:49:53 -0800 (PST)
In-Reply-To: <CALzJLG8WHJYQFEsxU39jgpMDFHPkHuDX6VU7vOcd+wqBedonfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-16 at 14:44 +0200, Saeed Mahameed wrote:
> On Wed, Feb 15, 2017 at 4:04 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Wed, 2017-02-15 at 05:29 -0800, Eric Dumazet wrote:
> >
> >>
> >> mlx4_eq_int() is a hard irq handler.
> >>
> >> How a tasklet could run in the middle of it ?
> >>
> >> A tasklet is a softirq handler.
> >
> > Speaking of mlx4_eq_int() , 50% of cycles are spent on mb() (mfence)
> > in eq_set_ci()
> >
> 
> I wonder why you have so many interrupts ? don't you have some kind of
> interrupt moderation ?
> what test are you running that got your CPU so busy.


Simply 8 RX queues. About 140,000 irq per second per RX queue,
for a moderate network load on 40Gbit NIC.

Interrupt moderation is a latency killer, we want our usec back.

> 
> > I wonder why this very expensive mb() is required, right before exiting
> > the interrupt handler.
> 
> to make sure the HW knows we handled Completions up to (ci) consumer
> index. so it will generate next irq.


So why a mb() is needed exactly ?

wmb() seems enough.
