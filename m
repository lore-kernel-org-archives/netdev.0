From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 7/8] sfc: Set net_device::num_rx_queues
 once we know the correct value
Date: Tue, 21 Sep 2010 14:57:03 -0700 (PDT)
Message-ID: <20100921.145703.189694076.davem@davemloft.net>
References: <1285008239.2282.110.camel@achroite.uk.solarflarecom.com>
	<1285008867.2323.60.camel@edumazet-laptop>
	<1285009546.2282.126.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50949
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752821Ab0IUV4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 17:56:44 -0400
In-Reply-To: <1285009546.2282.126.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 20 Sep 2010 20:05:46 +0100

> If RPS is enabled there's a separate kobject for each RX queue.  Those
> other drivers probably should be setting it.
> 
> Oh, but this only exists if CONFIG_RPS is enabled.  I think we need an
> inline function for setting this.

It's set in the core by alloc_netdev_mq(), you should never have to
set this in your driver.

And that also takes care of the CONFIG_RPS dependency in one spot,
another good argument for drivers never touching this value.

I'm not applying this patch.
