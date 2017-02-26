From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net] net/mlx4_en: fix overflow in mlx4_en_init_timestamp()
Date: Sun, 26 Feb 2017 19:28:03 +0200
Message-ID: <1102e4a7-fb39-4adc-8655-7fb873c43181@gmail.com>
References: <1487892163.9415.111.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34769 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751214AbdBZSiv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 13:38:51 -0500
Received: by mail-wm0-f65.google.com with SMTP id m70so10320979wma.1
        for <netdev@vger.kernel.org>; Sun, 26 Feb 2017 10:37:48 -0800 (PST)
In-Reply-To: <1487892163.9415.111.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 24/02/2017 1:22 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> The cited commit makes a great job of finding optimal shift/multiplier
> values assuming a 10 seconds wrap around, but forgot to change the
> overflow_period computation.
>
> It overflows in cyclecounter_cyc2ns(), and the final result is 804 ms,
> which is silly.
>
> Lets simply use 5 seconds, no need to recompute this, given how it is
> supposed to work.
>
> Later, we will use a timer instead of a work queue, since the new RX
> allocation schem will no longer need mlx4_en_recover_from_oom() and the
> service_task firing every 250 ms.
>
> Fixes: 31c128b66e5b ("net/mlx4_en: Choose time-stamping shift value according to HW frequency")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> Cc: Eugenia Emantayev <eugenia@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_clock.c |   18 +++++++---------
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h  |    1
>  2 files changed, 8 insertions(+), 11 deletions(-)
>

Reviewed-by: Tariq Toukan <tariqt@mellanox.com>

Thanks for your patch.
