From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: avoid unnecessary dirtying of critical
 fields
Date: Sun, 20 Nov 2016 09:15:02 -0800
Message-ID: <1479662102.8455.361.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1479500133.8455.295.camel@edumazet-glaptop3.roam.corp.google.com>
         <62f9c9ee-d710-7493-1094-e8ffe8aaa1ca@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35084 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750914AbcKTRPE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 12:15:04 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so26109078pga.2
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 09:15:04 -0800 (PST)
In-Reply-To: <62f9c9ee-d710-7493-1094-e8ffe8aaa1ca@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-11-20 at 17:14 +0200, Tariq Toukan wrote:
> Hi Eric,
> 
> Thanks for your patch.
> 
> On 18/11/2016 10:15 PM, Eric Dumazet wrote:
> > +
> > +		AVG_PERF_COUNTER(priv->pstats.rx_coal_avg, polled);
> Keep this perf stats update out of the if block.

This perf stat would be useless then with busy polling.

And this would be the the only source of false sharing in the driver.

Not that I particularly care, since AVG_PERF_COUNTER can not be enabled
without modifying / recompiling the driver.
