From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next] mlx4: do not fire tasklet unless necessary
Date: Thu, 16 Feb 2017 14:38:58 +0200
Message-ID: <CALzJLG9bFC1nVC1Sp3WiAf_OkO_6O9XYqJGRn21yg32NYey6Vw@mail.gmail.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36817 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754297AbdBPMjT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 07:39:19 -0500
Received: by mail-qt0-f193.google.com with SMTP id h53so1916782qth.3
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 04:39:19 -0800 (PST)
In-Reply-To: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2017 at 2:27 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> All rx and rx netdev interrupts are handled by respectively
> by mlx4_en_rx_irq() and mlx4_en_tx_irq() which simply schedule a NAPI.
>
> But mlx4_eq_int() also fires a tasklet to service all items that were
> queued via mlx4_add_cq_to_tasklet(), but this handler was not called
> unless user cqe was handled.
>
> This is very confusing, as "mpstat -I SCPU ..." show huge number of
> tasklet invocations.
>
> This patch saves this overhead, by carefully firing the tasklet directly
> from mlx4_add_cq_to_tasklet(), removing four atomic operations per IRQ.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> Cc: Saeed Mahameed <saeedm@mellanox.com>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>
