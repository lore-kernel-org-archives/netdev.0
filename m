From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next] mlx4: fix use-after-free in mlx4_en_fold_software_stats()
Date: Thu, 1 Dec 2016 17:23:10 +0200
Message-ID: <CALzJLG-4kbK=bnHrizOpJfaTJjvZQXOyNn=YHkwyb2xCf=Ti=g@mail.gmail.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161130150839.5203ece0@redhat.com> <1480521514.18162.191.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8pcuNo4uD3+dVms1gHT9=WfZAM1DDp_J10NgBZ7YZnEA@mail.gmail.com>
 <1480527321.18162.196.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG_aT1O1ergGRu8Z0u4nszKYao5RbPfb=1USptwFY1d7PQ@mail.gmail.com>
 <1480539652.18162.205.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161201133706.316428e9@redhat.com> <1480597326.18162.276.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35137 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754141AbcLAPXc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 10:23:32 -0500
Received: by mail-lf0-f67.google.com with SMTP id p100so19347700lfg.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 07:23:31 -0800 (PST)
In-Reply-To: <1480597326.18162.276.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 1, 2016 at 3:02 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> My recent commit to get more precise rx/tx counters in ndo_get_stats64()
> can lead to crashes at device dismantle, as Jesper found out.
>
> We must prevent mlx4_en_fold_software_stats() trying to access
> tx/rx rings if they are deleted.
>
> Fix this by adding a test against priv->port_up in
> mlx4_en_fold_software_stats()
>
> Calling mlx4_en_fold_software_stats() from mlx4_en_stop_port()
> allows us to eventually broadcast the latest/current counters to
> rtnetlink monitors.
>
> Fixes: 40931b85113d ("mlx4: give precise rx/tx bytes/packets counters")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-and-bisected-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Tested-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>
