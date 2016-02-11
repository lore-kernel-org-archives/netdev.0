From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 2/3] lan78xx: setting phy features in phy driver
Date: Thu, 11 Feb 2016 15:17:44 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404AC532@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D404AB9F9@CHN-SV-EXMX02.mchp-main.com>
 <56BBC0BB.3010100@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D404ABB4D@CHN-SV-EXMX02.mchp-main.com>
 <56BC089B.6090309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <opendmb@gmail.com>
To: <f.fainelli@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:58657 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750911AbcBKPRp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 10:17:45 -0500
In-Reply-To: <56BC089B.6090309@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'll submit patch for review.

- Woojung

> On 10/02/2016 15:18, Woojung.Huh@microchip.com wrote:
> >>> +static int lan88xx_config_init(struct phy_device *phydev)
> >>> +{
> >>> +	phydev->supported &= phydev->drv->features;
> >>> +	phydev->advertising &= phydev->drv->features;
> >>
> >> This looks suspicious, phy_probe() takes the driver supported features
> >> and assigns it to phydev->supported, and phydev->advertising, is not
> >> that working somehow?
> >>
> >> genphy_config_init() does look at the current MII_BMRS value to
> >> determine what is supported by the PHY, and masks it in
> >> phydev->supported, so that could indeed be an issue if we had not had a
> >> change to mask with the supported modes before.
> >>
> >> I think we need more explanation here as to what kind of bug you may
> >> have been observing, there could be one.
> >
> > SUPPORTED_Pause & SUPPORTED_Asym_Pause set at phydev->features
> are removed by genphy_config_init().
> > As you pointed, it may be better to modify genphy_config_init() than each
> driver's config_init routine.
> 
> I see, that is definitively a bug, we should not clear these bits if the
> Ethernet MAC driver asked for them.
> --
> Florian
