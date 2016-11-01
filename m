From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH v2 2/6] net: phy: broadcom: Add BCM54810 PHY entry
Date: Tue, 1 Nov 2016 12:43:39 -0400
Message-ID: <20161101164337.GA19654@broadcom.com>
References: <1477688219-3871-1-git-send-email-jon.mason@broadcom.com>
 <1477688219-3871-3-git-send-email-jon.mason@broadcom.com>
 <20161029081839.GA32579@lunn.ch>
 <20161101155950.GA19378@broadcom.com>
 <20161101162648.GG10785@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, rafal@milecki.pl,
        linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33527 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751723AbcKAQns (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 12:43:48 -0400
Received: by mail-pf0-f176.google.com with SMTP id d2so22902397pfd.0
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 09:43:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161101162648.GG10785@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 01, 2016 at 05:26:48PM +0100, Andrew Lunn wrote:
> > > > +	if (of_property_read_bool(np, "brcm,enet-phy-lane-swap")) {
> > > > +		/* Lane Swap - Undocumented register...magic! */
> > > > +		ret = bcm_phy_write_exp(phydev, MII_BCM54XX_EXP_SEL_ER + 0x9,
> > > > +					0x11B);
> > > > +		if (ret < 0)
> > > > +			return ret;
> > > > +	}
> > > > +
> > > 
> > > I wounder if this property could be made generic? What exactly are you
> > > swapping? Rx and Tx lanes? Maybe we should add it to phy.txt?
> > 
> > Are you envisioning adding a DT check (similar to the
> > of_property_read_bool above, only with a more generic string) in
> > phy_device_create(), which will then set a PHY device flag?  This flag
> > would then be checked for in the PHY driver and the appropriate action
> > taken (in this case the bcm_phy_write_exp above).
> 
> I would keep the parsing of the property in the driver. But if we
> think other PHYs could also support this feature, it would be good to
> avoid having "brcm,enet-phy-lane-swap", "marvell,enet-phy-lane-swap",
> "davicom,enet-phy-lane-swap", etc. It would be better to have one well
> defined property documented in phy.txt which any PHY is free to
> implement.

Okay, I understand what you are saying now.  I will assume that if
nothing exists today aside from this Broadcom errata, something in the
future will happen.  So, I agree that making it generic is a good idea.

I'll make the generic string be "enet-phy-lane-swap" (without the
previous "brcm"), and add the flag to phy.txt to document it.

Thanks,
Jon

> 
> 	Andrew
