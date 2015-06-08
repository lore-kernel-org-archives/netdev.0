From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] net: phy: dp83867: Add TI dp83867 phy
Date: Mon, 08 Jun 2015 11:03:49 -0700
Message-ID: <5575D905.6050307@gmail.com>
References: <1433255677-20293-1-git-send-email-dmurphy@ti.com> <556FBC3E.8050803@gmail.com> <5575A10B.8080701@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Dan Murphy <dmurphy@ti.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:34654 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbbFHSEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 14:04:53 -0400
Received: by qcej9 with SMTP id j9so53451358qce.1
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 11:04:53 -0700 (PDT)
In-Reply-To: <5575A10B.8080701@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/15 07:04, Dan Murphy wrote:
> Florian
>=20
> Thanks for the re-review
>=20
> On 06/03/2015 09:47 PM, Florian Fainelli wrote:
>> Le 06/02/15 07:34, Dan Murphy a =C3=A9crit :
>>> Add support for the TI dp83867 Gigabit ethernet phy
>>> device.
>>>
>>> The DP83867 is a robust, low power, fully featured
>>> Physical Layer transceiver with integrated PMD
>>> sublayers to support 10BASE-T, 100BASE-TX and
>>> 1000BASE-T Ethernet protocols.
>> Sorry for the late feedback, since this is a new driver, things outl=
ine
>> below can still be submitted as incremental fixes.
>>
>> [snip]
>>
>>> +Required properties:
>>> +	- reg - The ID number for the phy, usually a small integer
>>> +	- ti,rx_int_delay - RGMII Recieve Clock Delay - see dt-bindings/n=
et/ti-dp83867.h
>>> +		for applicable values
>>> +	- ti,tx_int_delay - RGMII Transmit Clock Delay - see dt-bindings/=
net/ti-dp83867.h
>>> +		for applicable values
>>> +	- ti,fifo_depth - Transmitt FIFO depth- see dt-bindings/net/ti-dp=
83867.h
>>> +		for applicable values
>> We typically use "-" to separate words in DT properties, not "_". I =
am
>> not sure about the required nature of these 3 proprietary/specific
>> properties, cannot there be good reset defaults from the HW in any c=
ase?
>=20
> Yes you are correct I will modify as an incremental fix.
>=20
> The hardware is defaulted to an internal delay of 2 ns.  This value n=
eeds to be adjusted
> per product based on trace length.  I would anticipate the DT propert=
ies to grow a little as the
> part gets used more.

Ok, that makes sense then.

>=20
>> You might want to add a reference to net/phy.txt for the remaiming D=
T
>> properties.
>>
>> [snip]
>>
>>> +
>>> +	if (phy_interface_is_rgmii(phydev)) {
>>> +		ret =3D phy_write(phydev, MII_DP83867_PHYCTRL,
>>> +			(dp83867->fifo_depth << DP83867_PHYCR_FIFO_DEPTH_SHIFT));
>>> +		if (ret)
>>> +			return ret;
>>> +	}
>>> +
>>> +	if ((phydev->interface >=3D PHY_INTERFACE_MODE_RGMII_ID) ||
>>> +	    (phydev->interface <=3D PHY_INTERFACE_MODE_RGMII_RXID)) {
>> This one has not been converted to use the phy_interface_is_rgmii()
>> helper, but in fact, once you do that, you could probably just add a=
n
>> early check for this condition, return, and reduce the indentation f=
or
>> the normal case/RGMII, and eliminate two redundant condition checks.
>=20
> This check is different then the generic RGMII check.  I am checking =
to see if the interface has the internal
> delay flag set.  The RGMII check is to broad.  Maybe I can add a help=
er for this
> if it makes sense thoughts?  Maybe a phy_interface_has_rgmii_int_dela=
y API just to enter this check.

Oh, I misread the range check. I do not think this deserves a helper
function for now, since that seems to be pretty unique and localized to
your driver for now, but if we have more than one users, factoring
things out would definitively make sense then.

Thanks.
--=20
=46lorian
