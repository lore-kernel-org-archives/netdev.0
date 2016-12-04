From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: Regression: [PATCH] mlx4: give precise rx/tx bytes/packets counters
Date: Sun, 4 Dec 2016 15:23:32 +0200
Message-ID: <CALzJLG-xERnkNEaC3+ikb6ZiWmzj9S1BAoJycYq1yp8AT+zuUQ@mail.gmail.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161130150839.5203ece0@redhat.com> <1480521514.18162.191.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8pcuNo4uD3+dVms1gHT9=WfZAM1DDp_J10NgBZ7YZnEA@mail.gmail.com>
 <1480527321.18162.196.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG_aT1O1ergGRu8Z0u4nszKYao5RbPfb=1USptwFY1d7PQ@mail.gmail.com>
 <1480539652.18162.205.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8O28ZBS3sdqLpohPZtpLbLs228K4aO6hYd4URsA3yefA@mail.gmail.com>
 <1480607729.18162.311.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480608517.18162.313.camel@edumazet-glaptop3.roam.corp.google.com> <1480613764.18162.324.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38753 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751111AbcLDNXy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 08:23:54 -0500
Received: by mail-wm0-f46.google.com with SMTP id f82so55474766wmf.1
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 05:23:53 -0800 (PST)
In-Reply-To: <1480613764.18162.324.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 1, 2016 at 7:36 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-12-01 at 08:08 -0800, Eric Dumazet wrote:
>> On Thu, 2016-12-01 at 07:55 -0800, Eric Dumazet wrote:
>>
>> > So removing the spinlock is doable, but needs to add a new parameter
>> > to mlx4_en_fold_software_stats() and call netdev_stats_to_stats64()
>> > before mlx4_en_fold_software_stats(dev)
>>
>> Untested patch would be :
>>
>>  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    2 -
>>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |   10 +----
>>  drivers/net/ethernet/mellanox/mlx4/en_port.c    |   24 +++++++++-----
>>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    3 +
>>  4 files changed, 23 insertions(+), 16 deletions(-)
>
> The patch is wrong, since priv->port_up could change to false while we
> are running and using the about to be deleted tx/rx rings.
>

Right, hence the regression Jesper saw ;).

>
> So the only safe thing to do is to remove the _bh suffix.
>
> Not worth trying to avoid taking a spinlock in this code.
>

Ack.
