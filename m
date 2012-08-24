From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Set device operstate at registration time
Date: Fri, 24 Aug 2012 12:48:15 -0400 (EDT)
Message-ID: <20120824.124815.1292475998883382478.davem@davemloft.net>
References: <1345497411.2659.28.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	shchepetkov@ispras.ru, bjorn@mork.no, mike@marineau.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907Ab2HXQsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 12:48:18 -0400
In-Reply-To: <1345497411.2659.28.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 20 Aug 2012 22:16:51 +0100

> This initialises the operstate synchronously at registration time
> only.

Ok, this looks good to me, applied.  Thanks Ben.

> This seems to deal properly with the registration-time problem, but not
> the case where a device is brought down and then up again.  Many but not
> all drivers that support carrier detection call netif_carrier_off() in
> their ndo_stop method.  Should the others be changed, or is there some
> way we can make that automatic?

There are several cases.

For example, if the device does not power down the PHY over stop/start
it should leave the carrier state alone.  This is the case for every
NIC that runs management firmware, which therefore needs the link to
stay up even when the NIC is administratively brought down.

If it does power down the PHY, that netif_carrier_off() call should
already be contained in the PHY powerdown code.
