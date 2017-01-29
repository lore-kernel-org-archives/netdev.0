From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] can: Fix kernel panic at security_sock_rcv_skb
Date: Sun, 29 Jan 2017 18:34:06 -0500 (EST)
Message-ID: <20170129.183406.1410276231781823069.davem@davemloft.net>
References: <0e458012-e97b-298d-296e-ed25e35689a0@hartkopp.net>
        <1484226099.15816.25.camel@edumazet-glaptop3.roam.corp.google.com>
        <1485533504.6360.62.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: socketcan@hartkopp.net, shuo.a.liu@intel.com,
        yanmin_zhang@linux.intel.com, shuox.liu@gmail.com,
        yanmin.zhang@intel.com, bo.he@intel.com, mkl@pengutronix.de,
        linux-can@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41332 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751011AbdA2Xk4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 18:40:56 -0500
In-Reply-To: <1485533504.6360.62.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Jan 2017 08:11:44 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Zhang Yanmin reported crashes [1] and provided a patch adding a
> synchronize_rcu() call in can_rx_unregister()
> 
> The main problem seems that the sockets themselves are not RCU
> protected.
> 
> If CAN uses RCU for delivery, then sockets should be freed only after
> one RCU grace period.
> 
> Recent kernels could use sock_set_flag(sk, SOCK_RCU_FREE), but let's
> ease stable backports with the following fix instead.
 ...
> Reported-by: Zhang Yanmin <yanmin.zhang@intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
