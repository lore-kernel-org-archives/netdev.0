From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next] mlx4: do not fire tasklet unless necessary
Date: Thu, 16 Feb 2017 14:44:56 +0200
Message-ID: <CALzJLG8WHJYQFEsxU39jgpMDFHPkHuDX6VU7vOcd+wqBedonfA@mail.gmail.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG9HWiNfGaWF_uB6F0BttPbzc_eSpow_zv7FwiK3GWoYQA@mail.gmail.com>
 <1487165355.1311.2.camel@edumazet-glaptop3.roam.corp.google.com> <1487167443.1311.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>, jackm@mellanox.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:34719 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753285AbdBPMpS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 07:45:18 -0500
Received: by mail-qk0-f173.google.com with SMTP id s186so14081808qkb.1
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 04:45:17 -0800 (PST)
In-Reply-To: <1487167443.1311.8.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 15, 2017 at 4:04 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2017-02-15 at 05:29 -0800, Eric Dumazet wrote:
>
>>
>> mlx4_eq_int() is a hard irq handler.
>>
>> How a tasklet could run in the middle of it ?
>>
>> A tasklet is a softirq handler.
>
> Speaking of mlx4_eq_int() , 50% of cycles are spent on mb() (mfence)
> in eq_set_ci()
>

I wonder why you have so many interrupts ? don't you have some kind of
interrupt moderation ?
what test are you running that got your CPU so busy.

> I wonder why this very expensive mb() is required, right before exiting
> the interrupt handler.

to make sure the HW knows we handled Completions up to (ci) consumer
index. so it will generate next irq.
