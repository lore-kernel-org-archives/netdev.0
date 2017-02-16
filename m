From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next] mlx4: do not fire tasklet unless necessary
Date: Thu, 16 Feb 2017 23:17:15 +0200
Message-ID: <CALzJLG_w2m9p3OQxi9c9=Y-RVKKLyce1b-WjoSvLUVGcWHNwYA@mail.gmail.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG9HWiNfGaWF_uB6F0BttPbzc_eSpow_zv7FwiK3GWoYQA@mail.gmail.com>
 <1487165355.1311.2.camel@edumazet-glaptop3.roam.corp.google.com>
 <1487167443.1311.8.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8WHJYQFEsxU39jgpMDFHPkHuDX6VU7vOcd+wqBedonfA@mail.gmail.com> <1487260187.1311.53.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>, jackm@mellanox.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36539 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933214AbdBPVRh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 16:17:37 -0500
Received: by mail-qk0-f193.google.com with SMTP id p22so4153568qka.3
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 13:17:36 -0800 (PST)
In-Reply-To: <1487260187.1311.53.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 16, 2017 at 5:49 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-02-16 at 14:44 +0200, Saeed Mahameed wrote:
>> On Wed, Feb 15, 2017 at 4:04 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Wed, 2017-02-15 at 05:29 -0800, Eric Dumazet wrote:
>> >
>> >>
>> >> mlx4_eq_int() is a hard irq handler.
>> >>
>> >> How a tasklet could run in the middle of it ?
>> >>
>> >> A tasklet is a softirq handler.
>> >
>> > Speaking of mlx4_eq_int() , 50% of cycles are spent on mb() (mfence)
>> > in eq_set_ci()
>> >
>>
>> I wonder why you have so many interrupts ? don't you have some kind of
>> interrupt moderation ?
>> what test are you running that got your CPU so busy.
>
>
> Simply 8 RX queues. About 140,000 irq per second per RX queue,
> for a moderate network load on 40Gbit NIC.
>

so i guess you are not busy polling .. and adaptive moderation decided
to lower down
rx-usecs for you, and you are looking to improve latency.

> Interrupt moderation is a latency killer, we want our usec back.
>

well, for RX we have adaptive moderation.
and for TX we have xmit more.
so interrupt moderation can be good if it is done right.

do i understand from this that you are against interrupt moderation ?

>>
>> > I wonder why this very expensive mb() is required, right before exiting
>> > the interrupt handler.
>>
>> to make sure the HW knows we handled Completions up to (ci) consumer
>> index. so it will generate next irq.
>
>
> So why a mb() is needed exactly ?
>
> wmb() seems enough.
>

Yes seems right, not sure why it is mb() though, i will have to check
and get back to you on this.
