From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: fix use-after-free in
 mlx4_en_fold_software_stats()
Date: Fri, 02 Dec 2016 13:36:23 -0500 (EST)
Message-ID: <20161202.133623.2263271525505379413.davem@davemloft.net>
References: <1480539652.18162.205.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161201133706.316428e9@redhat.com>
        <1480597326.18162.276.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, saeedm@dev.mellanox.co.il,
        netdev@vger.kernel.org, tariqt@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38342 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751307AbcLBShC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:37:02 -0500
In-Reply-To: <1480597326.18162.276.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Dec 2016 05:02:06 -0800

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

Applied.
