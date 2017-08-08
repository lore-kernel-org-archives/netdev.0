From: Murali Karicheri <m-karicheri2@ti.com>
Subject: skb allocation from interrupt handler?
Date: Tue, 8 Aug 2017 18:17:52 -0400
Message-ID: <598A3890.80705@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx194.ext.ti.com ([198.47.27.80]:40864 "EHLO
        lelnx194.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751931AbdHHWQy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 18:16:54 -0400
Received: from dflxv15.itg.ti.com ([128.247.5.124])
        by lelnx194.ext.ti.com (8.15.1/8.15.1) with ESMTP id v78MGsl3012455
        for <netdev@vger.kernel.org>; Tue, 8 Aug 2017 17:16:54 -0500
Received: from DFLE102.ent.ti.com (dfle102.ent.ti.com [10.64.6.23])
        by dflxv15.itg.ti.com (8.14.3/8.13.8) with ESMTP id v78MGsi0024013
        for <netdev@vger.kernel.org>; Tue, 8 Aug 2017 17:16:54 -0500
Received: from [158.218.103.210] (ileax41-snat.itg.ti.com [10.172.224.153])
        by dlep33.itg.ti.com (8.14.3/8.13.8) with ESMTP id v78MGrbM013461
        for <netdev@vger.kernel.org>; Tue, 8 Aug 2017 17:16:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there an skb_alloc function that can be used from interrupt handler? Looks like netdev_alloc_skb()
can't be used since I see following trace with kernel hack debug options enabled.

[  652.481713] [<c021007c>] (unwind_backtrace) from [<c020bdcc>] (show_stack+0x10/0x14)
[  652.481725] [<c020bdcc>] (show_stack) from [<c0517780>] (dump_stack+0x98/0xc4)
[  652.481736] [<c0517780>] (dump_stack) from [<c0256a70>] (___might_sleep+0x1b8/0x2a4)
[  652.481746] [<c0256a70>] (___might_sleep) from [<c0939e80>] (rt_spin_lock+0x24/0x5c)
[  652.481755] [<c0939e80>] (rt_spin_lock) from [<c07d827c>] (__netdev_alloc_skb+0xd0/0x254)
[  652.481774] [<c07d827c>] (__netdev_alloc_skb) from [<bf23a544>] (emac_rx_hardirq+0x374/0x554 [prueth])
[  652.481793] [<bf23a544>] (emac_rx_hardirq [prueth]) from [<c02925dc>] (__handle_irq_event_percpu+0x9c/0x128)

This is running under RT kernel off 4.9.y

-- 
Murali Karicheri
Linux Kernel, Keystone
