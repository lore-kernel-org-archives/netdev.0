From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] net: phy: dp83867: Add TI dp83867 phy
Date: Wed, 03 Jun 2015 19:47:26 -0700
Message-ID: <556FBC3E.8050803@gmail.com>
References: <1433255677-20293-1-git-send-email-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Dan Murphy <dmurphy@ti.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:33013 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbbFDCr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 22:47:28 -0400
Received: by obbea3 with SMTP id ea3so22996443obb.0
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 19:47:28 -0700 (PDT)
In-Reply-To: <1433255677-20293-1-git-send-email-dmurphy@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/02/15 07:34, Dan Murphy a =C3=A9crit :
> Add support for the TI dp83867 Gigabit ethernet phy
> device.
>=20
> The DP83867 is a robust, low power, fully featured
> Physical Layer transceiver with integrated PMD
> sublayers to support 10BASE-T, 100BASE-TX and
> 1000BASE-T Ethernet protocols.

Sorry for the late feedback, since this is a new driver, things outline
below can still be submitted as incremental fixes.

[snip]

> +Required properties:
> +	- reg - The ID number for the phy, usually a small integer
> +	- ti,rx_int_delay - RGMII Recieve Clock Delay - see dt-bindings/net=
/ti-dp83867.h
> +		for applicable values
> +	- ti,tx_int_delay - RGMII Transmit Clock Delay - see dt-bindings/ne=
t/ti-dp83867.h
> +		for applicable values
> +	- ti,fifo_depth - Transmitt FIFO depth- see dt-bindings/net/ti-dp83=
867.h
> +		for applicable values

We typically use "-" to separate words in DT properties, not "_". I am
not sure about the required nature of these 3 proprietary/specific
properties, cannot there be good reset defaults from the HW in any case=
?

You might want to add a reference to net/phy.txt for the remaiming DT
properties.

[snip]

> +
> +	if (phy_interface_is_rgmii(phydev)) {
> +		ret =3D phy_write(phydev, MII_DP83867_PHYCTRL,
> +			(dp83867->fifo_depth << DP83867_PHYCR_FIFO_DEPTH_SHIFT));
> +		if (ret)
> +			return ret;
> +	}
> +
> +	if ((phydev->interface >=3D PHY_INTERFACE_MODE_RGMII_ID) ||
> +	    (phydev->interface <=3D PHY_INTERFACE_MODE_RGMII_RXID)) {

This one has not been converted to use the phy_interface_is_rgmii()
helper, but in fact, once you do that, you could probably just add an
early check for this condition, return, and reduce the indentation for
the normal case/RGMII, and eliminate two redundant condition checks.

Thanks!
--=20
=46lorian
