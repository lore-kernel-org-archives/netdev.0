From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: do not fire tasklet unless necessary
Date: Wed, 15 Feb 2017 07:26:37 -0800
Message-ID: <1487172397.1311.23.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG9HWiNfGaWF_uB6F0BttPbzc_eSpow_zv7FwiK3GWoYQA@mail.gmail.com>
         <82f68be0-95fb-0d61-9d0a-4c74afb626b5@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, jackm@mellanox.com
To: "Matan Barak (External)" <matanb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36424 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751588AbdBOP0u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 10:26:50 -0500
Received: by mail-pf0-f193.google.com with SMTP id 19so8989236pfo.3
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 07:26:45 -0800 (PST)
In-Reply-To: <82f68be0-95fb-0d61-9d0a-4c74afb626b5@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-15 at 16:52 +0200, Matan Barak (External) wrote:

> So, in case of RDMA CQs, we add some per-CQE overhead of comparing the 
> list pointers and condition upon that. Maybe we could add an 
> invoke_tasklet boolean field on mlx4_cq and return its value from 
> mlx4_cq_completion.
> That's way we could do invoke_tasklet |= mlx4_cq_completion(....);
> 
> Outside the while loop we could just
> if (invoke_tasklet)
>      tasklet_schedule
> 
> Anyway, I guess that even with per-CQE overhead, the performance impact 
> here is pretty negligible - so I guess that's fine too :)


Real question or suggestion would be to use/fire a tasklet only under
stress.

Firing a tasklet adds a lot of latencies for user-space CQ completion,
since softirqs might have to be handled by a kernel thread (ksoftirqd)

I would be surprised if no customer was hit by your commit,
( net/mlx4_core: Use tasklet for user-space CQ completion events )
especially when using specific (RT) scheduler classes.
