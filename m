From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression: [PATCH] mlx4: give precise rx/tx bytes/packets
 counters
Date: Thu, 01 Dec 2016 09:08:50 -0800
Message-ID: <1480612130.18162.321.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161130150839.5203ece0@redhat.com>
         <1480521514.18162.191.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8pcuNo4uD3+dVms1gHT9=WfZAM1DDp_J10NgBZ7YZnEA@mail.gmail.com>
         <1480527321.18162.196.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG_aT1O1ergGRu8Z0u4nszKYao5RbPfb=1USptwFY1d7PQ@mail.gmail.com>
         <1480539652.18162.205.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8O28ZBS3sdqLpohPZtpLbLs228K4aO6hYd4URsA3yefA@mail.gmail.com>
         <1480607729.18162.311.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG_=Z_anekLaiT0giK+RaOGRWmvK6MUP4UWXqsQQysR55w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34317 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750738AbcLARJw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 12:09:52 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so5139022pgc.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 09:09:52 -0800 (PST)
In-Reply-To: <CALzJLG_=Z_anekLaiT0giK+RaOGRWmvK6MUP4UWXqsQQysR55w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-01 at 18:33 +0200, Saeed Mahameed wrote:

> Thanks for the detailed answer !!

You're welcome.

> 
> BTW you went 5 steps ahead of my original question :)), so far you
> already have a patch without locking at all (really impressive).
> 
> What i wanted to ask originally, was regarding the "_bh", i didn't
> mean to completely remove the "spin_lock_bh",
> I meant, what happens if we replace "spin_lock_bh"  with "spin_lock",
> without disabling bh ?
> I gues raw "sping_lock" handles points (2 to 4) from above, but it
> won't handle long irqs.

Thats a very good point, the _bh prefix can totally be removed, since
stats_lock is only acquired from process context.
