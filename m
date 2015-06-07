From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: fec: ptp: correct the ENET_ATCOR
 value
Date: Sun, 07 Jun 2015 15:31:04 -0700 (PDT)
Message-ID: <20150607.153104.632430918032409604.davem@davemloft.net>
References: <1433496128-3102-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	B20596@freescale.com
To: B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbbFGWbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 18:31:05 -0400
In-Reply-To: <1433496128-3102-1-git-send-email-B38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <B38611@freescale.com>
Date: Fri, 5 Jun 2015 17:22:08 +0800

> From: Fugang Duan <b38611@freescale.com>
> 
> The current driver adjust freq formula is:
> fe * diff = ppb * pc
> Note:
>   fe: ENET ref clock frequency in Hz
>   diff = inc_corr - inc: difference between default increment and correction increment
>   ppb: parts per billion adjustment from base
>   pc: correction period (in number of fe clock cycles)
> 
> The correction increment will be used after N cycles of regular increments,
> not every N cycles (with N being the correction period). For example, set ENET_ATCOR=4,
> INC=8, INC_CORR=9, there will be 4 increments of 8 (ENET_ATINC[INC]) , followed by 1
> increment of 9 (ENET_ATINC[INC_CORR]).
> 
> So, the correct formula is:
> 	fe * diff = ppb * (pc + 1)
> 
> For ENET_ATCOR, a value 0 disables the correction counter and no corrections occur.
> So base on the origin formula, set pc = pc > 1 ? pc - 1 : pc.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Applied, thank you.
