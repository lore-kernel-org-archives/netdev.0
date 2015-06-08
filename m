From: Dan Murphy <dmurphy@ti.com>
Subject: Re: [PATCH v2] net: phy: dp83867: Add TI dp83867 phy
Date: Mon, 8 Jun 2015 09:04:59 -0500
Message-ID: <5575A10B.8080701@ti.com>
References: <1433255677-20293-1-git-send-email-dmurphy@ti.com> <556FBC3E.8050803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:40562 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751459AbbFHOE5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2015 10:04:57 -0400
In-Reply-To: <556FBC3E.8050803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46lorian

Thanks for the re-review

On 06/03/2015 09:47 PM, Florian Fainelli wrote:
> Le 06/02/15 07:34, Dan Murphy a =C3=A9crit :
>> Add support for the TI dp83867 Gigabit ethernet phy
>> device.
>>
>> The DP83867 is a robust, low power, fully featured
>> Physical Layer transceiver with integrated PMD
>> sublayers to support 10BASE-T, 100BASE-TX and
>> 1000BASE-T Ethernet protocols.
> Sorry for the late feedback, since this is a new driver, things outli=
ne
> below can still be submitted as incremental fixes.
>
> [snip]
>
>> +Required properties:
>> +	- reg - The ID number for the phy, usually a small integer
>> +	- ti,rx_int_delay - RGMII Recieve Clock Delay - see dt-bindings/ne=
t/ti-dp83867.h
>> +		for applicable values
>> +	- ti,tx_int_delay - RGMII Transmit Clock Delay - see dt-bindings/n=
et/ti-dp83867.h
>> +		for applicable values
>> +	- ti,fifo_depth - Transmitt FIFO depth- see dt-bindings/net/ti-dp8=
3867.h
>> +		for applicable values
> We typically use "-" to separate words in DT properties, not "_". I a=
m
> not sure about the required nature of these 3 proprietary/specific
> properties, cannot there be good reset defaults from the HW in any ca=
se?

Yes you are correct I will modify as an incremental fix.

The hardware is defaulted to an internal delay of 2 ns.  This value nee=
ds to be adjusted
per product based on trace length.  I would anticipate the DT propertie=
s to grow a little as the
part gets used more.

> You might want to add a reference to net/phy.txt for the remaiming DT
> properties.
>
> [snip]
>
>> +
>> +	if (phy_interface_is_rgmii(phydev)) {
>> +		ret =3D phy_write(phydev, MII_DP83867_PHYCTRL,
>> +			(dp83867->fifo_depth << DP83867_PHYCR_FIFO_DEPTH_SHIFT));
>> +		if (ret)
>> +			return ret;
>> +	}
>> +
>> +	if ((phydev->interface >=3D PHY_INTERFACE_MODE_RGMII_ID) ||
>> +	    (phydev->interface <=3D PHY_INTERFACE_MODE_RGMII_RXID)) {
> This one has not been converted to use the phy_interface_is_rgmii()
> helper, but in fact, once you do that, you could probably just add an
> early check for this condition, return, and reduce the indentation fo=
r
> the normal case/RGMII, and eliminate two redundant condition checks.

This check is different then the generic RGMII check.  I am checking to=
 see if the interface has the internal
delay flag set.  The RGMII check is to broad.  Maybe I can add a helper=
 for this
if it makes sense thoughts?  Maybe a phy_interface_has_rgmii_int_delay =
API just to enter this check.

Dan

> Thanks!


--=20
------------------
Dan Murphy
