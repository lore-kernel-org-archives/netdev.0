From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-2.6] net: Keep TX queues stopped as long as the
 physical device is absent
Date: Mon, 16 May 2011 22:53:54 +0100
Message-ID: <1305582834.2885.55.camel@bwh-desktop>
References: <1305579891.2885.44.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:2089 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756422Ab1EPVx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 17:53:56 -0400
In-Reply-To: <1305579891.2885.44.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-16 at 22:04 +0100, Ben Hutchings wrote:
> netif_device_detach() stops all TX queues, but there is nothing to
> prevent them from being restarted.  In fact, netif_tx_unlock() may now
                          rescheduled
> do this.  Add another queue state flag that is set while the device is
> absent, and make netif_tx_queue_frozen_or_stopped() test it.  Rename the
> function to netif_tx_queue_blocked() since it makes little sense to keep
> adding flags to its name.
[...]

So I suspect this isn't a real problem - as long as the device remains
detached then the driver won't (or shouldn't) start the queues again.
Although the queues may be scheduled (which this patch doesn't change),
ndo_start_xmit() will not be called.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

