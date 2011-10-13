From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 3/3] netdev/phy: Add driver for Broadcom BCM8706 10G
 Ethernet PHY
Date: Wed, 12 Oct 2011 18:31:29 -0600
Message-ID: <20111013003129.GC14042@ponder.secretlab.ca>
References: <1318442783-29058-1-git-send-email-david.daney@cavium.com>
 <1318442783-29058-4-git-send-email-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, afleming@gmail.com
To: David Daney <david.daney@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1318442783-29058-4-git-send-email-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 12, 2011 at 11:06:23AM -0700, David Daney wrote:
> Add a driver and PHY_ID number for said device.  This is a 10Gig PHY
> which uses MII_ADDR_C45 addressing, it is always 10G full duplex, so
> there is no autonegotiation.  All we do is report link state and send
> interrupts when it changes.
> 
> If the PHY has a device tree of_node associated with it, the
> "broadcom,c45-reg-init" property is used to supply register
> initialization values when config_init() is called.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>
> ---
>  .../devicetree/bindings/net/broadcom-bcm8706.txt   |   28 +++
>  drivers/net/phy/Kconfig                            |    5 +
>  drivers/net/phy/Makefile                           |    1 +
>  drivers/net/phy/bcm8706.c                          |  212 ++++++++++++++++++++
>  include/linux/brcmphy.h                            |    1 +
>  5 files changed, 247 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/broadcom-bcm8706.txt
>  create mode 100644 drivers/net/phy/bcm8706.c
> 
> diff --git a/Documentation/devicetree/bindings/net/broadcom-bcm8706.txt b/Documentation/devicetree/bindings/net/broadcom-bcm8706.txt
> new file mode 100644
> index 0000000..d58bea9
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/broadcom-bcm8706.txt
> @@ -0,0 +1,28 @@
> +The Broadcom BCM8706 is a 10G Ethernet PHY.  It has these bindings in
> +addition to the standard PHY bindings.
> +
> +Compatible: Should contain "broadcom,bcm8706" and
> +            "ethernet-phy-ieee802.3-c45"
> +
> +Optional Properties:
> +
> +- broadcom,c45-reg-init : one of more sets of 4 cells.  The first cell
> +  is the device type, the second a register address, the third cell
> +  contains a mask to be ANDed with the existing register value, and
> +  the fourth cell is ORed with he result to yield the new register
> +  value.

... a mask value of '0' should also guarantee that the driver does not do a read before the write.

What have we got so far in this regard for other phys and devices?  I
don't think it necessary to put 'c45' in the property name.  reg-init
should be sufficient.  I'd like to hear from others if it would be
valuable to have a 'reg-init-sequence' property of the above format.

What does the device type cell indicate?  Wouldn't the driver
naturally have the device id from the address of the cell?

> +static int __init bcm8706_init(void)
> +{
> +	int ret;
> +
> +	ret = phy_driver_register(&bcm8706_driver);
> +
> +	return ret;
> +}
> +module_init(bcm8706_init);

or simply:
static int __init bcm8706_init(void)
{
	return phy_driver_register(&bcm8706_driver);
}
module_init(bcm8706_init);

Otherwise the driver code seems to be fine.

g.
