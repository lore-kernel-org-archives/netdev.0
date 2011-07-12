From: David Miller <davem@davemloft.net>
Subject: Re: softirqs are invoked while bottom halves are masked
Date: Tue, 12 Jul 2011 05:13:16 -0700 (PDT)
Message-ID: <20110712.051316.1963034055315982365.davem@davemloft.net>
References: <1310465411.3314.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAMJ=MEeC1hoqufs7AfFRn3yJoC8mdw7v+14N+7e=wQuJefm4_w@mail.gmail.com>
	<20110712.050817.1253941735409335652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, patrickdepinguin+linuxppc@gmail.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com
To: ronny.meeus@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33629 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753028Ab1GLMOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 08:14:24 -0400
In-Reply-To: <20110712.050817.1253941735409335652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 12 Jul 2011 05:08:17 -0700 (PDT)

> From: Ronny Meeus <ronny.meeus@gmail.com>
> Date: Tue, 12 Jul 2011 14:03:04 +0200
> 
>> but we still see the issue "BUG: sleeping function called from invalid context":
>> 
>> [   91.015989] BUG: sleeping function called from invalid context at
>> include/linux/skbuff.h:786
>> [   91.117096] in_atomic(): 1, irqs_disabled(): 0, pid: 1865, name: NMTX_T1842
>> [   91.200461] Call Trace:
>> [   91.229672] [ec58bbd0] [c000789c] show_stack+0x78/0x18c (unreliable)
>> [   91.305791] [ec58bc10] [c0022900] __might_sleep+0x100/0x118
>> [   91.372524] [ec58bc20] [c029f8d8] dpa_tx+0x128/0x758
> 
> Because this dpa driver's transmit method is doing something else that
> is not allowed in software interrupt context.
> 
> You must remove all things that might sleep in this driver's
> ->ndo_start_xmit method, and I do mean everything.

Also this whole HW QOS feature bit facility is beyond bogus.

What if the user enables a qdisc that the hardware can't handle, or a
configuration of a hw supported qdisc that the hardware can't support?

What if I have packet classification and packet actions enabled in the
packet scheduler?

These changes are terrible, and we really need you guys to sort out
your problems with these changes yoursleves because your wounds are
entirely self-inflicted and totally not our problem.
