From: "Langer, Thomas" <thomas.langer@intel.com>
Subject: RE: [RFC v3 1/3] NET: PHY: adds driver for Intel XWAY PHY
Date: Sat, 4 Jun 2016 14:43:11 +0000
Message-ID: <0DAF21CFE1B20740AE23D6AF6E54843F1E503ECE@IRSMSX101.ger.corp.intel.com>
References: <1465040728-4904-1-git-send-email-hauke@hauke-m.de>
 <1465040728-4904-2-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "alexander.stein@systec-electronic.com"
	<alexander.stein@systec-electronic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"john@phrozen.org" <john@phrozen.org>,
	"openwrt@kresin.me" <openwrt@kresin.me>,
	"Mehrtens, Hauke" <hauke.mehrtens@intel.com>,
	"daniel.schwierzeck@gmail.com" <daniel.schwierzeck@gmail.com>,
	"eckert.florian@googlemail.com" <eckert.florian@googlemail.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Hauke Mehrtens <hauke@hauke-m.de>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53305 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119AbcFDOnX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 10:43:23 -0400
In-Reply-To: <1465040728-4904-2-git-send-email-hauke@hauke-m.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Hauke,

[...]
> +
> +static int xway_gphy_ack_interrupt(struct phy_device *phydev)
> +{
> +	int reg;
> +
> +	/**
> +	 * Possible IRQ numbers:
> +	 * - IM3_IRL18 for GPHY0
> +	 * - IM3_IRL17 for GPHY1

These are references to the SoC interrupts.

> +	 *
> +	 * Due to a silicon bug IRQ lines are not really independent from
> +	 * each other. Sometimes the two lines are driven at the same time
> +	 * if only one GPHY core raises the interrupt.

So this errata sounds like a SoC errata, not an errata for the PHY.

> +	 */
> +	reg = phy_read(phydev, XWAY_MDIO_ISTAT);
> +
> +	return (reg < 0) ? reg : 0;
> +}
> +
[...]
> +
> +static struct phy_driver xway_gphy[] = {
> +	{
> +		.phy_id		= PHY_ID_PHY11G_1_3,
> +		.phy_id_mask	= 0xffffffff,
> +		.name		= "Intel XWAY PHY11G (PEF 7071/PEF 7072)
> v1.3",
> +		.features	= (PHY_GBIT_FEATURES |
> SUPPORTED_Pause |
> +				   SUPPORTED_Asym_Pause),
> +		 /* there is an errata regarding irqs in this rev */

And then this is comment is also now valid.
What about a system with a single external phy connected,
on a non-Lantiq/Intel SoC?

I think the feasibility of using interrupts is not related to the phy version,
but indirectly by the version of the SoC it is integrated.

So maybe he use of interrupts (on these SoCs) should be controlled by devicetree or
network driver, where the SoC type and version can be handled?

> +		.flags		= 0,
> +		.config_init	= xway_gphy_config_init,
> +		.config_aneg	= xway_gphy14_config_aneg,
> +		.read_status	= genphy_read_status,
> +		.ack_interrupt	= xway_gphy_ack_interrupt,
> +		.did_interrupt	= xway_gphy_did_interrupt,
> +		.config_intr	= xway_gphy_config_intr,
> +		.suspend	= genphy_suspend,
> +		.resume		= genphy_resume,
> +	}, {
[...]

Regards,
Thomas
