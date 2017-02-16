From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next] mlx4: do not fire tasklet unless necessary
Date: Thu, 16 Feb 2017 14:34:46 +0200
Message-ID: <CALzJLG8JpzM4KjYFtLdG9XwTE+eMixPp_KRB9xdYAM962bZi-A@mail.gmail.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG9HWiNfGaWF_uB6F0BttPbzc_eSpow_zv7FwiK3GWoYQA@mail.gmail.com>
 <82f68be0-95fb-0d61-9d0a-4c74afb626b5@mellanox.com> <1487172397.1311.23.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Matan Barak (External)" <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, jackm@mellanox.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34179 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753434AbdBPMfH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 07:35:07 -0500
Received: by mail-qk0-f194.google.com with SMTP id e1so2147839qkh.1
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 04:35:07 -0800 (PST)
In-Reply-To: <1487172397.1311.23.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 15, 2017 at 5:26 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2017-02-15 at 16:52 +0200, Matan Barak (External) wrote:
>
>> So, in case of RDMA CQs, we add some per-CQE overhead of comparing the
>> list pointers and condition upon that. Maybe we could add an
>> invoke_tasklet boolean field on mlx4_cq and return its value from
>> mlx4_cq_completion.
>> That's way we could do invoke_tasklet |= mlx4_cq_completion(....);
>>
>> Outside the while loop we could just
>> if (invoke_tasklet)
>>      tasklet_schedule
>>
>> Anyway, I guess that even with per-CQE overhead, the performance impact
>> here is pretty negligible - so I guess that's fine too :)
>
>
> Real question or suggestion would be to use/fire a tasklet only under
> stress.
>
> Firing a tasklet adds a lot of latencies for user-space CQ completion,
> since softirqs might have to be handled by a kernel thread (ksoftirqd)
>

At least for mlx4_en driver we don't need this tasklet and it is only
adding this overhead. (we have napi)

we must consider removing it for mlx4_en cqs and move the tasklet
handling to mlx4_ib.

I will ack the patch.
