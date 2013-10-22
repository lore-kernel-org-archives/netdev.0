From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: fix incorrect use of spin_lock_bh in interrupts
Date: Tue, 22 Oct 2013 02:55:14 -0400 (EDT)
Message-ID: <20131022.025514.1611245390510932009.davem@davemloft.net>
References: <alpine.LRH.2.02.1310211950360.5325@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: klassert@mathematik.tu-chemnitz.de, netdev@vger.kernel.org
To: mpatocka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab3JVGzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 02:55:15 -0400
In-Reply-To: <alpine.LRH.2.02.1310211950360.5325@file01.intranet.prod.int.rdu2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 21 Oct 2013 19:53:22 -0400 (EDT)

> The functions mdio_read and mdio_write may be called from interrupt
> context. Consequently, we must use spin_lock_irqsave instead of
> spin_lock_bh.
> 
> This patch should be backported to stable kernels.

vortex_down() does a lot of other things which are really dangerous
from an interrupt handler, such as del_timer_sync().

The real fix for this bug is to defer the vortex_error() work into
a workqueue, and thus process context, like every other driver does.
