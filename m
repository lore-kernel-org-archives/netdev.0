From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFA] sch_generic: fix carrier-on bug?
Date: Wed, 17 Oct 2007 23:26:05 -0700 (PDT)
Message-ID: <20071017.232605.74748149.davem@davemloft.net>
References: <20071016215555.GA4732@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44822
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750969AbXJRGZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 02:25:53 -0400
In-Reply-To: <20071016215555.GA4732@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 16 Oct 2007 17:55:55 -0400

> While looking at a net driver with the following construct,
> 
> 	if (!netif_carrier_ok(dev))
> 		netif_carrier_on(dev);
> 
> it stuck me that the netif_carrier_ok() check was redundant, since
> netif_carrier_on() checks bit __LINK_STATE_NOCARRIER anyway.  This is
> the same reason why netif_queue_stopped() need not be called prior to
> netif_wake_queue().
> 
> This is true, but there is however an unwanted side effect from assuming
> that netif_carrier_on() can be called multiple times:  it touches the
> watchdog, regardless of pre-existing carrier state.
> 
> The fix:  move watchdog-up inside the bit-cleared code path.
> 
> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

I see no problems with this patch, I'll apply it, thanks!
