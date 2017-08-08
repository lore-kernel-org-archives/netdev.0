From: Matteo Croce <mcroce@redhat.com>
Subject: Re: skb allocation from interrupt handler?
Date: Wed, 09 Aug 2017 00:29:15 +0200
Message-ID: <1502231355.23698.5.camel@redhat.com>
References: <598A3890.80705@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Murali Karicheri <m-karicheri2@ti.com>,
        "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32986 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751970AbdHHW3S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Aug 2017 18:29:18 -0400
In-Reply-To: <598A3890.80705@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il giorno mar, 08/08/2017 alle 18.17 -0400, Murali Karicheri ha
scritto:
> Is there an skb_alloc function that can be used from interrupt
> handler? Looks like netdev_alloc_skb()
> can't be used since I see following trace with kernel hack debug
> options enabled.
> 
> [  652.481713] [<c021007c>] (unwind_backtrace) from [<c020bdcc>]
> (show_stack+0x10/0x14)
> [  652.481725] [<c020bdcc>] (show_stack) from [<c0517780>]
> (dump_stack+0x98/0xc4)
> [  652.481736] [<c0517780>] (dump_stack) from [<c0256a70>]
> (___might_sleep+0x1b8/0x2a4)
> [  652.481746] [<c0256a70>] (___might_sleep) from [<c0939e80>]
> (rt_spin_lock+0x24/0x5c)
> [  652.481755] [<c0939e80>] (rt_spin_lock) from [<c07d827c>]
> (__netdev_alloc_skb+0xd0/0x254)
> [  652.481774] [<c07d827c>] (__netdev_alloc_skb) from [<bf23a544>]
> (emac_rx_hardirq+0x374/0x554 [prueth])
> [  652.481793] [<bf23a544>] (emac_rx_hardirq [prueth]) from
> [<c02925dc>] (__handle_irq_event_percpu+0x9c/0x128)
> 
> This is running under RT kernel off 4.9.y
> 

netdev_alloc_skb() passes GFP_ATOMIC to alloc_skb() so it should work
in an interrupt handler too.

-- 
Matteo Croce
per aspera ad upstream
