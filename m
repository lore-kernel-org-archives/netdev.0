From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/7] IBM Akebono: Add support for a new PHY to the IBM
 emac driver
Date: Wed, 6 Nov 2013 16:40:10 +0000
Message-ID: <1383756010.1520.5.camel@bwh-desktop.uk.level5networks.com>
References: <1383629471-16979-1-git-send-email-alistair@popple.id.au>
	 <1383681240.4776.97.camel@pasglop>
	 <1383693110.2868.17.camel@bwh-desktop.uk.level5networks.com>
	 <3555701.fBbreSn0Lp@mexican>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	<netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	"David S. Miller" <davem@davemloft.net>
To: Alistair Popple <alistair@popple.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:64431 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436Ab3KFQkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 11:40:19 -0500
In-Reply-To: <3555701.fBbreSn0Lp@mexican>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-06 at 12:34 +1100, Alistair Popple wrote:
> On Tue, 5 Nov 2013 23:11:50 Ben Hutchings wrote:
> > On Wed, 2013-11-06 at 06:54 +1100, Benjamin Herrenschmidt wrote:
> 
> [snip]
> 
> > > It's an SoC bit so there's little point making it generally
> > > selectable by the user.
> > 
> > I think a better way to do this is:
> > 
> > config IBM_EMAC_RGMII_WOL
> > 	bool "IBM EMAC RGMII wake-on-LAN support"
> > 	depends on MY_WONDERFUL_NEW_SOC || COMPILE_TEST
> > 	default y if MY_WONDERFUL_NEW_SOC
> > 
> > Then anyone making an API change that affects this driver can check that
> > it still complies.
> 
> The method used in this patch is the same as what is currently used by the 
> other IBM EMAC PHY interfaces (eg. config IBM_EMAC_ZMII etc). I'm happy to 
> send a patch to update all of those as well for consistency but that would 
> mean adding what each platform requires into EMACS Kconfig as well.
> 
> Personally I think it is nicer to keep the definitions of what each platform 
> requires in one place (ie. arch/powerpc/platforms/44x/Kconfig) as it is 
> consistent with what we do for other 44x drivers, however I am happy to use 
> the above method if people think it's better.

Yes, I see your point.

> Alternatively we could do something like this:
> 
> config IBM_EMAC_RGMII_WOL
>         bool
>         default y if COMPILE_TEST
>         default n
> 
> This would leave the platform dependencies as they are currently but still 
> allow compile testing.

It still shouldn't default to y in that case.  Instead you can make the
symbol conditionally configurable:

config IBM_EMAC_RGMII_WOL
	bool "IBM EMAC RGMII wake-on-LAN support" if COMPILE_TEST

and then select this from your platform Kconfig as you intended.

(There is no need to put 'default n' as that's implicit for a
configurable symbol.  But it doesn't hurt either.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
