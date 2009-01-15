From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.29] can: fix slowpath issue in hrtimer callback
 function
Date: Wed, 14 Jan 2009 21:07:07 -0800 (PST)
Message-ID: <20090114.210707.32386748.davem@davemloft.net>
References: <496D97DC.9020408@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52416
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754714AbZAOFHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:07:06 -0500
In-Reply-To: <496D97DC.9020408@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Wed, 14 Jan 2009 08:44:28 +0100

> Due to the loopback functionality in can_send() we can not invoke it from hardirq context which was done inside the bcm_tx_timeout_handler() hrtimer callback:
> 
> 
> [  700.361154]  [<c012228c>] warn_slowpath+0x80/0xb6
> [  700.361163]  [<c013d559>] valid_state+0x125/0x136
> [  700.361171]  [<c013d858>] mark_lock+0x18e/0x332
> [  700.361180]  [<c013e300>] __lock_acquire+0x12e/0xb1e
> [  700.361189]  [<f8ab5915>] bcm_tx_timeout_handler+0x0/0xbc [can_bcm]
> [  700.361198]  [<c031e20a>] dev_queue_xmit+0x191/0x479
> [  700.361206]  [<c01262a7>] __local_bh_disable+0x2b/0x64
> [  700.361213]  [<c031e20a>] dev_queue_xmit+0x191/0x479
> [  700.361225]  [<f8aa69a1>] can_send+0xd7/0x11a [can]
> [  700.361235]  [<f8ab522b>] bcm_can_tx+0x9d/0xd9 [can_bcm]
> [  700.361245]  [<f8ab597f>] bcm_tx_timeout_handler+0x6a/0xbc [can_bcm]
> [  700.361255]  [<f8ab5915>] bcm_tx_timeout_handler+0x0/0xbc [can_bcm]
> [  700.361263]  [<c0134143>] __run_hrtimer+0x5a/0x86
> [  700.361273]  [<f8ab5915>] bcm_tx_timeout_handler+0x0/0xbc [can_bcm]
> [  700.361282]  [<c0134a50>] hrtimer_interrupt+0xb9/0x110
> 
> 
> This patch moves the rest of the functionality from the hrtimer callback to the already existing tasklet to fix this slowpath problem.
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

Applied, thanks Oliver.
