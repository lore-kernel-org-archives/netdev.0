From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH v2 2/6] net: phy: broadcom: Add BCM54810 PHY entry
Date: Tue, 1 Nov 2016 11:59:53 -0400
Message-ID: <20161101155950.GA19378@broadcom.com>
References: <1477688219-3871-1-git-send-email-jon.mason@broadcom.com>
 <1477688219-3871-3-git-send-email-jon.mason@broadcom.com>
 <20161029081839.GA32579@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
 bcm-kernel-feedback-list@broadcom.com, rafal@milecki.pl,
 David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20161029081839.GA32579@lunn.ch>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 29, 2016 at 10:18:39AM +0200, Andrew Lunn wrote:
> On Fri, Oct 28, 2016 at 04:56:55PM -0400, Jon Mason wrote:
> > The BCM54810 PHY requires some semi-unique configuration, which results
> > in some additional configuration in addition to the standard config.
> > Also, some users of the BCM54810 require the PHY lanes to be swapped.
> > Since there is no way to detect this, add a device tree query to see if
> > it is applicable.
> > 
> > Inspired-by: Vikas Soni <vsoni@broadcom.com>
> > Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> > ---
> >  drivers/net/phy/Kconfig    |  2 +-
> >  drivers/net/phy/broadcom.c | 58 +++++++++++++++++++++++++++++++++++++++++++++-
> >  include/linux/brcmphy.h    | 10 ++++++++
> 
> Hi Jon
> 
> The binding documentation is missing.
> 
> > +	if (of_property_read_bool(np, "brcm,enet-phy-lane-swap")) {
> > +		/* Lane Swap - Undocumented register...magic! */
> > +		ret = bcm_phy_write_exp(phydev, MII_BCM54XX_EXP_SEL_ER + 0x9,
> > +					0x11B);
> > +		if (ret < 0)
> > +			return ret;
> > +	}
> > +
> 
> I wounder if this property could be made generic? What exactly are you
> swapping? Rx and Tx lanes? Maybe we should add it to phy.txt?

Are you envisioning adding a DT check (similar to the
of_property_read_bool above, only with a more generic string) in
phy_device_create(), which will then set a PHY device flag?  This flag
would then be checked for in the PHY driver and the appropriate action
taken (in this case the bcm_phy_write_exp above).

If so, I cam completely fine doing this.  I think the only caveat
would be that this would be creating a generic interface for only 1
user.  If you envision this being used by others, then disregard my
concern.

Thanks,
Jon

> 
> 	  Andrew
