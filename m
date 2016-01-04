From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 12/24] of: phy: Only register a phy device
 for phys
Date: Mon, 4 Jan 2016 22:04:51 +0100
Message-ID: <20160104210451.GB7485@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
 <1451929022-5580-13-git-send-email-andrew@lunn.ch>
 <568ACF80.5070105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35203 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751908AbcADVEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 16:04:52 -0500
Content-Disposition: inline
In-Reply-To: <568ACF80.5070105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 04, 2016 at 12:01:04PM -0800, Florian Fainelli wrote:
> On 04/01/16 09:36, Andrew Lunn wrote:
> > We will soon support devices other than phys on the mdio bus. Look at
> > a child's compatibility string to determine if it is a phy, before
> > registering a phy device.
> > 
> > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> > ---
> 
> [snip]
> 
> > +	if (of_get_phy_id(child, &phy_id) != -EINVAL)
> > +		return true;
> > +
> > +	if (of_device_is_compatible(child, "ethernet-phy-ieee802.3-c45"))
> > +		return true;
> 
> Is there a particular reason not to check for
> "ethernet-phy-ieee802.3-c22 here?

Humm interesting. Didn't even know it was a valid compatible string.
Also, Linux does not know it is a valid compatible string:

~/linux$ grep -r "ethernet-phy-ieee802.3-c22" ./drivers
~/linux$

It is however used in a number of DT files and is documented in
Documentation/devicetree/bindings/net/phy.txt.

I will add it here as well.
 
> > +
> > +	if (!of_find_property(child, "compatible", NULL))
> > +		return true;
> 
> That seems reasonable, we should probably make the compatible string for
> PHY Device Tree nodes not an optional property anymore though, but
> that's for a separate change and topic.

Yes, printing a warning here would be good.

     Andrew
