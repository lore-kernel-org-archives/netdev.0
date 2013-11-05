From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/7] IBM Akebono: Add support for a new PHY to the IBM
 emac driver
Date: Tue, 5 Nov 2013 23:11:50 +0000
Message-ID: <1383693110.2868.17.camel@bwh-desktop.uk.level5networks.com>
References: <1383629471-16979-1-git-send-email-alistair@popple.id.au>
	 <1383629471-16979-3-git-send-email-alistair@popple.id.au>
	 <1383675404.2868.8.camel@bwh-desktop.uk.level5networks.com>
	 <1383681240.4776.97.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alistair Popple <alistair@popple.id.au>, <netdev@vger.kernel.org>,
	<linuxppc-dev@lists.ozlabs.org>,
	"David S. Miller" <davem@davemloft.net>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:15547 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755526Ab3KEXLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 18:11:54 -0500
In-Reply-To: <1383681240.4776.97.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-06 at 06:54 +1100, Benjamin Herrenschmidt wrote:
> On Tue, 2013-11-05 at 18:16 +0000, Ben Hutchings wrote:
> > On Tue, 2013-11-05 at 16:31 +1100, Alistair Popple wrote:
> > [...]
> > > --- a/drivers/net/ethernet/ibm/emac/Kconfig
> > > +++ b/drivers/net/ethernet/ibm/emac/Kconfig
> > > @@ -55,6 +55,10 @@ config IBM_EMAC_RGMII
> > >  	bool
> > >  	default n
> > >  
> > > +config IBM_EMAC_RGMII_WOL
> > > +	bool
> > > +	default n
> > > +
> > [...]
> > 
> > So no-one can even build-test this at present!
> 
> Patch 7/7 adds the select to the platform, isn't that sufficient ?

I suppose so, but I don't think that went to netdev.

> It's an SoC bit so there's little point making it generally
> selectable by the user.

I think a better way to do this is:

config IBM_EMAC_RGMII_WOL
	bool "IBM EMAC RGMII wake-on-LAN support"
	depends on MY_WONDERFUL_NEW_SOC || COMPILE_TEST
	default y if MY_WONDERFUL_NEW_SOC

Then anyone making an API change that affects this driver can check that
it still complies.

Ben.

> Alistair: The commit name should be different, it's not a PHY you are
> adding, it's a PHY interface (the PHY itself is off chip).


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
