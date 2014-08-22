From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Fri, 22 Aug 2014 10:46:25 -0700 (PDT)
Message-ID: <20140822.104625.2141682975890196702.davem@davemloft.net>
References: <1408612178-13906-1-git-send-email-b38611@freescale.com>
	<1408612178-13906-2-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932510AbaHVRq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 13:46:26 -0400
In-Reply-To: <1408612178-13906-2-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Thu, 21 Aug 2014 17:09:38 +0800

> The current kernel hang on i.MX6SX with rootfs mount from MMC.
> The root cause is that ptp uses a periodic timer to access enet register
> even if ipg clock is disabled.
> 
> FEC ptp driver start one period timer to read 1588 counter register in the
> ptp init function that is called after FEC driver is probed.
> 
> To save power, after FEC probe finish, FEC driver disable all clocks including
> ipg clock that is needed for register access.
> 
> i.MX5x, i.MX6q/dl/sl FEC register access don't cause system hang when ipg clock
> is disabled, just return zero value. But for i.MX6sx SOC, it cause system hang.
> 
> To avoid the issue, we need to check ptp clock status before ptp timer count access.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied, thanks.
