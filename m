From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/6] netpoll: break recursive loop in netpoll rx path
Date: Mon, 26 Jun 2006 00:04:38 -0700 (PDT)
Message-ID: <20060626.000438.74564809.davem@davemloft.net>
References: <200606250847.k5P8lUEX020903@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20415
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932319AbWFZHEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 03:04:41 -0400
To: akpm@osdl.org
In-Reply-To: <200606250847.k5P8lUEX020903@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Sun, 25 Jun 2006 01:47:30 -0700

> The netpoll system currently has a rx to tx path via:
> 
> netpoll_rx
>  __netpoll_rx
>   arp_reply
>    netpoll_send_skb
>     dev->hard_start_tx
> 
> This rx->tx loop places network drivers at risk of inadvertently causing a
> deadlock or BUG halt by recursively trying to acquire a spinlock that is
> used in both their rx and tx paths (this problem was origionally reported
> to me in the 3c59x driver, which shares a spinlock between the
> boomerang_interrupt and boomerang_start_xmit routines).
> 
> This patch breaks this loop, by queueing arp frames, so that they can be
> responded to after all receive operations have been completed.  Tested by
> myself and the reported with successful results.
> 
> Specifically it was tested with netdump.  Heres the BZ with details:
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=194055
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Acked-by: Matt Mackall <mpm@selenic.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, thanks.
