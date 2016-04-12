From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH RFT 2/2] macb: kill PHY reset code
Date: Tue, 12 Apr 2016 16:57:21 +0200
Message-ID: <570D0CD1.6070304@atmel.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <2811962.eGX2i5RJbZ@wasted.cogentembedded.com>
 <20160411022802.GB4307@lunn.ch> <570CBE42.50309@atmel.com>
 <570CFE13.3040100@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:32786 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756445AbcDLO5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 10:57:05 -0400
In-Reply-To: <570CFE13.3040100@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/04/2016 15:54, Sergei Shtylyov a =E9crit :
> Hello.
>=20
> On 4/12/2016 12:22 PM, Nicolas Ferre wrote:
>=20
>>>> With  the 'phylib' now  being aware of  the "reset-gpios" PHY node=
 property,
>>>> there should be no need to frob the PHY reset in this  driver anym=
ore...
>>>>
>>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com=
>
>>>>
>>>> ---
>>>>   drivers/net/ethernet/cadence/macb.c |   17 -----------------
>>>>   drivers/net/ethernet/cadence/macb.h |    1 -
>>>>   2 files changed, 18 deletions(-)
>>>>
>>>> Index: net-next/drivers/net/ethernet/cadence/macb.c
>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>> --- net-next.orig/drivers/net/ethernet/cadence/macb.c
>>>> +++ net-next/drivers/net/ethernet/cadence/macb.c
> [...]
>>>> @@ -2977,18 +2976,6 @@ static int macb_probe(struct platform_de
>>>>   	else
>>>>   		macb_get_hwaddr(bp);
>>>>
>>>> -	/* Power up the PHY if there is a GPIO reset */
>>>> -	phy_node =3D  of_get_next_available_child(np, NULL);
>>>> -	if (phy_node) {
>>>> -		int gpio =3D of_get_named_gpio(phy_node, "reset-gpios", 0);
>>>> -
>>>> -		if (gpio_is_valid(gpio)) {
>>>> -			bp->reset_gpio =3D gpio_to_desc(gpio);
>>>> -			gpiod_direction_output(bp->reset_gpio, 1);
>>>
>>> Hi Sergei
>>>
>>> The code you are deleting would of ignored the flags in the gpio
>>
>> I don't parse this.
>=20
>> The code deleted does take the flag into account.
>=20
>     Not really -- you need to call of_get_named_gpio_flags() (with a =
valid=20
> last argument) for that.

Yep,

>> And the DT property
>> associated to it seems correct to me (I mean, with proper flag
>> specification).
>=20
>     It apparently is not as it have GPIO_ACTIVE_HIGH and the driver a=
ssumes=20
> active-low reset signal.

Yes, logic was inverted and... anyway, the flag never used for real...
Thanks Sergei.

No problem for me accepting a patch for the at91-vinco.dts.

Bye,
--=20
Nicolas Ferre
