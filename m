From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/core: use local_bh_disable() in netif_rx_ni()
Date: Tue, 20 Jun 2017 13:08:40 -0400 (EDT)
Message-ID: <20170620.130840.472295224655944129.davem@davemloft.net>
References: <20170616172400.10809-1-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, tglx@linutronix.de
To: bigeasy@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38658 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdFTRIn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 13:08:43 -0400
In-Reply-To: <20170616172400.10809-1-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Fri, 16 Jun 2017 19:23:59 +0200

> In 2004 [0] netif_rx_ni() gained a preempt_disable() section around
> netif_rx() and its do_softirq() + testing for it. The do_softirq() part
> is required because netif_rx() raises the softirq but does not invoke
> it. The preempt_disable() is required to avoid running the BH in
> parallel.
> All this can be avoided be putting this into a local_bh_disable()ed
> section. The local_bh_enable() part will invoke do_softirq() if
> required.
> 
> [0] Make netif_rx_ni preempt-safe
>     http://oss.sgi.com/projects/netdev/archive/2004-10/msg02211.html
> 
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Why make extra work?  The current code is cheaper.

Doing all of that dance with the local_bh_enable() function call is
more expensive than the inlined counter bump and softirq state
check.

I'm not applying this without a better justification, sorry.
