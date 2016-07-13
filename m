From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3] Marvell phy: add fiber status check and configuration
 for some phys
Date: Wed, 13 Jul 2016 17:39:53 +0200
Message-ID: <20160713153953.GC6667@lunn.ch>
References: <20160404132552.GH21828@lunn.ch>
 <570BFF50.6060909@gmail.com>
 <d3b31c38-a15c-bf49-d787-1a7dcd11849d@nexvision.fr>
 <9dd03fd9-1241-fc7d-ead3-feb7e918d4c3@nexvision.fr>
 <20160602145636.GA15379@lunn.ch>
 <75f458dd-6f6e-153d-eff1-d2b1112f268f@nexvision.fr>
 <20160712155739.GB31432@lunn.ch>
 <843ddd47-0394-88ee-39d9-f50bb7256225@nexvision.fr>
 <20160713132632.GA6667@lunn.ch>
 <cbe62b8d-3796-a514-9783-c1ddae5711a6@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41813 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751659AbcGMPkK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 11:40:10 -0400
Content-Disposition: inline
In-Reply-To: <cbe62b8d-3796-a514-9783-c1ddae5711a6@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >>>> +static int marvell_resume_fiber(struct phy_device *phydev)
> >>>> +{
> >>>> +	int err;
> >>>> +
> >>>> +	/* Resume the fiber mode first */
> >>>> +	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
> >>>> +	if (err < 0)
> >>>> +		goto error;
> >>>> +
> >>>> +	err = genphy_resume(phydev);
> >>>> +	if (err < 0)
> >>>> +		goto error;
> >>>> +
> >>>> +	/* Then, the copper link */
> >>>> +	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
> >>>> +	if (err < 0)
> >>>> +		goto error;
> >>>> +
> >>>> +	return genphy_resume(phydev);
> >>>
> >>> Should it be resumed twice? Or just once at the end?  Same question
> >>> for suspend.
> >>
> >> I don't understand your question.
> > 
> > You call genphy_resume(phydev) twice. Once is sufficient.
> 
> Yes, but it's normal because each interface could be suspended or resumed independently.

> genphy_* functions use BMCR register which are identical between
> fiber and copper link. But each link has its own register to change.

Ah! Now i get it. I think you need a comment here. Something like:

    /* With the page set, use the generic resume */

What i was worried about is that there is some reference counting
going on inside these functions. And so suspending the same phydev
multiple times will mess up the reference counts. But no, it just
twiddles a register bit, so that is O.K.

	 Andrew
