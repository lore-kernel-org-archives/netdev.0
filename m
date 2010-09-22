From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 7/8] sfc: Set net_device::num_rx_queues once we know the correct value
Date: Wed, 22 Sep 2010 02:31:36 +0100
Message-ID: <1285106878.2697.96.camel@localhost>
References: <1285008239.2282.110.camel@achroite.uk.solarflarecom.com> <1285008867.2323.60.camel@edumazet-laptop> <1285009546.2282.126.camel@achroite.uk.solarflarecom.com> <20100921.145703.189694076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12534 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755183Ab0IVBbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 21:31:39 -0400
Content-Disposition: inline
In-Reply-To: <20100921.145703.189694076.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-09-21 at 14:57 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 20 Sep 2010 20:05:46 +0100
> 
> > If RPS is enabled there's a separate kobject for each RX queue.  Those
> > other drivers probably should be setting it.
> > 
> > Oh, but this only exists if CONFIG_RPS is enabled.  I think we need an
> > inline function for setting this.
> 
> It's set in the core by alloc_netdev_mq(), you should never have to
> set this in your driver.

That specifies the maximum possible number of queues, but we don't
require that the actual number of TX queues (real_num_tx_queues) is the
same as the maximum (num_tx_queues) and nor should we assume that of RX
queues.  I don't think we should require that the maximum numbers of RX
and TX queues are the same either, for that matter.

> And that also takes care of the CONFIG_RPS dependency in one spot,
> another good argument for drivers never touching this value.
> 
> I'm not applying this patch.

Right, but we do need to have some way for drivers to specify the actual
number of RX queues.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
