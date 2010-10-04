From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmtr: fix tr%d in dmesg
Date: Sun, 03 Oct 2010 20:56:32 -0700 (PDT)
Message-ID: <20101003.205632.104074109.davem@davemloft.net>
References: <alpine.SOC.1.00.1010022056000.27121@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44235
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751810Ab0JDD4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Oct 2010 23:56:11 -0400
In-Reply-To: <alpine.SOC.1.00.1010022056000.27121@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Meelis Roos <mroos@linux.ee>
Date: Sat, 2 Oct 2010 21:35:15 +0300 (EEST)

> ibmtr and ibmtr_cs show tr%d in dmesg after alloc_netdev() but before 
> register_netdev(). Fix it like e100 does - put a different name into 
> dev->name until the device gets registered. I/O port seems to be unique
> enough and is available for the time of printk messages. With the fix, 
> dmesg shows
> 
> ibmtr@0a20: ISA P&P 16/4 Adapter/A (short) | 16/4 ISA-16 Adapter found
> ibmtr@0a20: using irq 3, PIOaddr a20, 64K shared RAM.
> ibmtr@0a20: Hardware address : 00:40:aa:a9:03:98
> ibmtr@0a20: Shared RAM paging disabled. ti->page_mask 0
> ibmtr@0a20: Maximum Receive Internet Protocol MTU 16Mbps: 16344, 4Mbps: 6104
> tr0: port 0xa20, irq 3,  mmio 0xd4850000, sram 0xd0000, hwaddr=00:40:aa:a9:03:98
> 
> Signed-off-by: Meelis Roos <mroos@linux.ee>

That may be how e100 does it, but this is a very ugly hack and
an abuse of netdev->name

Instead, the more correct way to fit this is to use dev_info(),
dev_err(), and friends.  It will both print the correct stuff,
and also document the probing path messages that occur before
the net device is registered.

So please correct the prolem that way, thank you.
