From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: add support of ethtool get_regs
Date: Sat, 09 May 2015 21:01:28 -0400 (EDT)
Message-ID: <20150509.210128.2284066611245510581.davem@davemloft.net>
References: <20150509211746.GY2067@n2100.arm.linux.org.uk>
	<CAOMZO5A2POPCYHzotc5SEhtmCuBrXiK7bdjF=UeiXZEqcnGMag@mail.gmail.com>
	<554E8735.302@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: festevam@gmail.com, linux@arm.linux.org.uk, B38611@freescale.com,
	Frank.Li@freescale.com, LW@karo-electronics.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47037 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbbEJBBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 21:01:32 -0400
In-Reply-To: <554E8735.302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 10 May 2015 00:16:21 +0200

> Hi Fabio,
> 
> On 09/05/15 23:59, Fabio Estevam wrote:
>> Philippe,
>>
>> On Sat, May 9, 2015 at 6:17 PM, Russell King - ARM Linux
>> <linux@arm.linux.org.uk>  wrote:
>>
>>> Using memcpy_fromio() to copy device registers is not a good idea -
>>> it can use a variable access size which can cause bus faults.
>>
>> An example on how memcpy_fromio() can be avoided in get_regs:
>> drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
> 
> Thanks for pointing me this example. I've already send a patch,
> and I've used drivers/net/ethernet/freescale/gianfar_ethtool.c
> as example. I hope it's a good example too.

I think you need to be much more careful and conservative in your
implementation.

You should skip I/O addresses that don't have defined registers
at those offsets for the chip in question.

Also, you should _very_ carefully evaluate each and every register you
dump and potentially skip certain registers which have strong negative
side effects if read arbitrarily.

For example, dumping the interrupt status register could cause pending
interrupt status to be cleared, and thus cause the driver to lose
interrupts and subsequently packet processing will hang.
