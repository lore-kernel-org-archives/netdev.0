From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/1] driver: ipvlan: Free ipvl_port directly
 with kfree instead of kfree_rcu
Date: Tue, 06 Dec 2016 07:18:30 -0800
Message-ID: <1481037510.18162.583.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481032489-7864-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, maheshb@google.com, edumazet@google.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36699 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752294AbcLFPSd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 10:18:33 -0500
Received: by mail-pg0-f65.google.com with SMTP id x23so20146350pgx.3
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 07:18:33 -0800 (PST)
In-Reply-To: <1481032489-7864-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-06 at 21:54 +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <gfree.wind@gmail.com>
> 
> There is no one which may reference the ipvlan port when free it in
> ipvlan_port_create and ipvlan_port_destroy. So it is unnecessary to
> use kfree_rcu.

You did not really explain _why_ it was safe/unnecessary.
Why should anyone trust you ?

The reason an RCU grace period is not needed is that
netdev_rx_handler_unregister() already enforces a grace period.

My guess is ipvlan copied code in macvlan.

At the time macvlan was written, commit
00cfec37484761a44 ("net: add a synchronize_net() in
netdev_rx_handler_unregister()") was not there yet.

macvlan could be changed the same way.
