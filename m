From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] flexcan: fix flood of irq's after error condition
 triggered
Date: Tue, 18 Oct 2011 23:58:59 -0400 (EDT)
Message-ID: <20111018.235859.1583989908694487368.davem@davemloft.net>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16D09892@exch01-aklnz.MARINE.NET.INT>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Reuben.Dowle@navico.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57120 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753662Ab1JSD7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 23:59:02 -0400
In-Reply-To: <70F6AAAFDC054F41B9994A9BCD3DF64E16D09892@exch01-aklnz.MARINE.NET.INT>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Reuben Dowle" <Reuben.Dowle@navico.com>
Date: Wed, 12 Oct 2011 16:41:11 +1300

> On my i.MX28 development kit board, I am able to use the flexcan module without problems, until I introduce a bus error by disconnecting the cable. As soon as this is done, the cpu usage goes to 100% percent due to the irq handler being called constantly.
> 
> It seems this error can be traced to the irq handler not clearing the irq flags. The flexcan driver is enabling several interrupts, but only clearing one of them.
> 
>>From the user manual:
> 
> 25.6.8 Error and Status Register (HW_CAN_ESR)
> This register reflects various error conditions, some general status of the device and it is
> the source of four interrupts to the ARM. The reported error conditions are those that
> occurred since the last time the ARM read this register. The ARM read action clears bits.
> Bits are status bits. Most bits in this register are read-only, except TWRN_INT, RWRN_INT,
> BOFF_INT, WAK_INT and ERR_INT, which are interrupt flags that can be cleared by
> writing 1 to them (writing 0 has no effect).
> 
> This is ambiguous. It says that reading clears the bits, but then says that some of the bits can be cleared by writing 1 to them. In practice it seems that all the ones listed above as being able to be cleared by writing 1 to them MUST be cleared by writing 1 to them.
> 
> Signed-off-by: Reuben Dowle <reuben.dowle@navico.com>

This patch does not apply properly to net-next tree, please respin it
into a properly applying patch.

You also need to properly format the text of your commit message, put
line breaks at 80 columns please.
