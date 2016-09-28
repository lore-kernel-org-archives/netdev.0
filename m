From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Wed, 28 Sep 2016 18:16:53 +0200
Message-ID: <20160928161653.GA25553@lunn.ch>
References: <1475062449-22168-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        f.fainelli@gmail.com, Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35252 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932824AbcI1QQ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 12:16:56 -0400
Content-Disposition: inline
In-Reply-To: <1475062449-22168-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +Optional properties:
> +- vsc8531,vddmac	: The vddmac in mV.
> +- vsc8531,edge-slowdown	: % the edge should be slowed down relative to
> +			  the fastest possible edge time. Native sign
> +			  need not enter.
> +			  Edge rate sets the drive strength of the MAC
> +			  interface output signals.  Changing the drive
> +			  strength will affect the edge rate of the output
> +			  signal.  The goal of this setting is to help
> +			  reduce electrical emission (EMI) by being able
> +			  to reprogram drive strength and in effect slow
> +			  down the edge rate if desired.  Table 5 shows the

Hi Raju

There is no table five here? Is that a reference to a data sheet
table?

> +Example:
> +
> +        vsc8531_0: ethernet-phy@0 {
> +                compatible = "ethernet-phy-id0007.0570";
> +                vsc8531,vddmac		= /bits/ 16 <MSCC_VDDMAC_3300>;
> +                vsc8531,edge-slowdown	= /bits/ 8  <17>;

No, real values please:

                vsc8531,vddmac		= <2000>;
                vsc8531,edge-slowdown	= <21>;

The driver should then do the maths to figure out the nearest magic
value to write to the register, or complain the settings are out of
range with an -EINVAL.

FYI: No floating point maths are allowed in the kernel.

   Andrew
