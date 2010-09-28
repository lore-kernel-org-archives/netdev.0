From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 00/17] netdev: Fix queue count
 initialisation
Date: Tue, 28 Sep 2010 13:02:07 +0100
Message-ID: <1285675327.2282.1.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
	 <20100927.221240.28820650.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:5548 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689Ab0I1MCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 08:02:11 -0400
In-Reply-To: <20100927.221240.28820650.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-09-27 at 22:12 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 27 Sep 2010 19:23:11 +0100
> 
> > This adds the functions:
> > - netif_set_real_num_rx_queues() - set actual number of RX queues used
> > - netif_copy_real_num_queues() - copy queue counts from another device
> > 
> > and changes all drivers that currently set
> > net_device::real_num_tx_queues to use netif_set_real_num_tx_queues()
> > and/or these functions.
> > 
> > The changes are compile-tested only, except that:
> > - sfc and 8021q have been briefly tested
> > - gianfar and mv643xx_eth have not been compiled, since they are
> >   platform-specific
> > 
> > I noticed that the bonding driver sets its numbers of queues without
> > regard to its slave devices.  This makes some sense since a bond device
> > initially has no slave devices.  However, it seems to mean that a bond
> > device can pass up an skb with an out-of-range queue_index, triggering a
> > warning in get_rps_cpu().
> 
> Series applied, thanks Ben.

That seems a bit premature, as the driver maintainers have not had a
chance to review these.  If it's not too late, perhaps you could roll
these changes back for now.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

