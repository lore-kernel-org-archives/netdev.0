From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH v3 0/6] add NS2 support to bgmac
Date: Tue, 1 Nov 2016 16:01:02 -0400
Message-ID: <20161101200101.GB26962@broadcom.com>
References: <1478022694-25308-1-git-send-email-jon.mason@broadcom.com>
 <cc2554bf-2700-9d9b-b012-15e82681b31b@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>, rafal@milecki.pl,
        bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: Scott Branden <scott.branden@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cc2554bf-2700-9d9b-b012-15e82681b31b@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 01, 2016 at 11:01:19AM -0700, Scott Branden wrote:
> Hi Jon,
> 
> On 16-11-01 10:51 AM, Jon Mason wrote:
> >Changes in v3:
> >* Clean-up the bgmac DT binding doc (per Rob Herring)
> >* Document the lane swap binding and make it generic (Per Andrew Lunn)
> Where is the documentation of the lane swap binding?

Sent out the wrong branch :(

Sending out v4 shortly with this patch.

> 
> >
> >
> >Changes in v2:
> >* Remove the PHY power-on (per Andrew Lunn)
> >* Misc PHY clean-ups regarding comments and #defines (per Andrew Lunn)
> >  This results on none of the original PHY code from Vikas being
> >  present.  So, I'm removing him as an author and giving him
> >  "Inspired-by" credit.
> >* Move PHY lane swapping to PHY driver (per Andrew Lunn and Florian
> >  Fainelli)
> >* Remove bgmac sleep (per Florian Fainelli)
> >* Re-add bgmac chip reset (per Florian Fainelli and Ray Jui)
> >* Rebased on latest net-next
> >* Added patch for bcm54xx_auxctl_read, which is used in the BCM54810
> >
> >
> >Add support for the amac found in the Broadcom Northstar2 SoC to the
> >bgmac driver.  This necessitates adding support to connect to an
> >externally defined phy (as described in the device tree) in the driver.
> >These phy changes are in addition to the changes necessary to get NS2
> >working.
> >
> >
> >Jon Mason (6):
> >  net: phy: broadcom: add bcm54xx_auxctl_read
> >  net: phy: broadcom: Add BCM54810 PHY entry
> >  Documentation: devicetree: net: add NS2 bindings to amac
> >  net: ethernet: bgmac: device tree phy enablement
> >  net: ethernet: bgmac: add NS2 support
> >  arm64: dts: NS2: add AMAC ethernet support
> >
> > .../devicetree/bindings/net/brcm,amac.txt          |  16 ++--
> > arch/arm64/boot/dts/broadcom/ns2-svk.dts           |   5 ++
> > arch/arm64/boot/dts/broadcom/ns2.dtsi              |  12 +++
> > drivers/net/ethernet/broadcom/bgmac-bcma.c         |  48 ++++++++++
> > drivers/net/ethernet/broadcom/bgmac-platform.c     | 100 ++++++++++++++++++++-
> > drivers/net/ethernet/broadcom/bgmac.c              |  55 ++----------
> > drivers/net/ethernet/broadcom/bgmac.h              |   8 ++
> > drivers/net/phy/Kconfig                            |   2 +-
> > drivers/net/phy/broadcom.c                         |  68 +++++++++++++-
> > include/linux/brcmphy.h                            |  11 +++
> > 10 files changed, 268 insertions(+), 57 deletions(-)
> >
