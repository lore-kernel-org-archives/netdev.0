From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: Set device operstate at registration time
Date: Fri, 24 Aug 2012 17:53:55 +0100
Message-ID: <1345827235.2694.12.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345497411.2659.28.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120824.124815.1292475998883382478.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <shemminger@vyatta.com>,
	<shchepetkov@ispras.ru>, <bjorn@mork.no>, <mike@marineau.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:19125 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752682Ab2HXQx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 12:53:59 -0400
In-Reply-To: <20120824.124815.1292475998883382478.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-24 at 12:48 -0400, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 20 Aug 2012 22:16:51 +0100
> 
> > This initialises the operstate synchronously at registration time
> > only.
> 
> Ok, this looks good to me, applied.  Thanks Ben.
> 
> > This seems to deal properly with the registration-time problem, but not
> > the case where a device is brought down and then up again.  Many but not
> > all drivers that support carrier detection call netif_carrier_off() in
> > their ndo_stop method.  Should the others be changed, or is there some
> > way we can make that automatic?
> 
> There are several cases.
> 
> For example, if the device does not power down the PHY over stop/start
> it should leave the carrier state alone.  This is the case for every
> NIC that runs management firmware, which therefore needs the link to
> stay up even when the NIC is administratively brought down.
> 
> If it does power down the PHY, that netif_carrier_off() call should
> already be contained in the PHY powerdown code.

Right, that makes sense to me.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
