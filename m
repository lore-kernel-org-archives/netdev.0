From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net/mlx4_en: reception NAPI/IRQ race breaker
Date: Sun, 26 Feb 2017 09:40:36 -0800
Message-ID: <1488130836.9415.155.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG-OcTAKkRQQHXV=8N-m+yATaX76UpGE4eWgK_8N52YePg@mail.gmail.com>
         <1488130457.9415.153.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34921 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdBZRkj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 12:40:39 -0500
Received: by mail-pg0-f68.google.com with SMTP id 1so9998427pgz.2
        for <netdev@vger.kernel.org>; Sun, 26 Feb 2017 09:40:38 -0800 (PST)
In-Reply-To: <1488130457.9415.153.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-02-26 at 09:34 -0800, Eric Dumazet wrote:

> I do not believe this bug is mlx4 specific.
> 
> Anything doing the following while hard irq were not masked :
> 
> local_bh_disable();
> napi_reschedule(&priv->rx_cq[ring]->napi);
> local_bh_enable();
> 
> Like in mlx4_en_recover_from_oom()
> 
> Can trigger the issue really.
> 
> Unfortunately I do not see how core layer can handle this.
> Only the driver hard irq could possibly know that it could not grab
> NAPI_STATE_SCHED

Actually we could use an additional bit for that, that the driver would
set even if NAPI_STATE_SCHED could not be grabbed.

Let me try something.
