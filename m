From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH RFT 2/2] macb: kill PHY reset code
Date: Tue, 12 Apr 2016 16:45:27 +0200
Message-ID: <570D0A07.2030104@atmel.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <2811962.eGX2i5RJbZ@wasted.cogentembedded.com>
 <20160411022802.GB4307@lunn.ch> <570CBE42.50309@atmel.com>
 <20160412134001.GB29895@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160412134001.GB29895@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 12/04/2016 15:40, Andrew Lunn a =E9crit :
> On Tue, Apr 12, 2016 at 11:22:10AM +0200, Nicolas Ferre wrote:
>> Le 11/04/2016 04:28, Andrew Lunn a =E9crit :
>>> On Sat, Apr 09, 2016 at 01:25:03AM +0300, Sergei Shtylyov wrote:
>>>> With  the 'phylib' now  being aware of  the "reset-gpios" PHY node=
 property,
>>>> there should be no need to frob the PHY reset in this  driver anym=
ore...
>>>>
>>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com=
>
>>>>
>>>> ---
>>>>  drivers/net/ethernet/cadence/macb.c |   17 -----------------
>>>>  drivers/net/ethernet/cadence/macb.h |    1 -
>>>>  2 files changed, 18 deletions(-)
>>>>
>>>> Index: net-next/drivers/net/ethernet/cadence/macb.c
>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>> --- net-next.orig/drivers/net/ethernet/cadence/macb.c
>>>> +++ net-next/drivers/net/ethernet/cadence/macb.c
>>>> @@ -2884,7 +2884,6 @@ static int macb_probe(struct platform_de
>>>>  					      =3D macb_clk_init;
>>>>  	int (*init)(struct platform_device *) =3D macb_init;
>>>>  	struct device_node *np =3D pdev->dev.of_node;
>>>> -	struct device_node *phy_node;
>>>>  	const struct macb_config *macb_config =3D NULL;
>>>>  	struct clk *pclk, *hclk =3D NULL, *tx_clk =3D NULL;
>>>>  	unsigned int queue_mask, num_queues;
>>>> @@ -2977,18 +2976,6 @@ static int macb_probe(struct platform_de
>>>>  	else
>>>>  		macb_get_hwaddr(bp);
>>>> =20
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
>> I don't parse this.
>>
>> The code deleted does take the flag into account. And the DT propert=
y
>> associated to it seems correct to me (I mean, with proper flag
>> specification).
>=20
> Hi Nicolas
> =20
> of_get_named_gpio() does not do anything with the flags. So for
> example,
>=20
> 			gpios =3D <&gpio0 12 GPIO_ACTIVE_LOW>;
>=20
> the GPIO_ACTIVE_LOW would be ignored. If you want the flags to be
> respected, you need to use the gpiod API for all calls, in particular=
,
> you need to use something which calls gpiod_get_index(), since that i=
s
> the only function to call gpiod_parse_flags() to translate
> GPIO_ACTIVE_LOW into a flag within the gpio descriptor.

Ok, I remember what confused me now: this code, used to be something ar=
ound:
devm_gpiod_get_optional(&bp->pdev->dev, "phy-reset", GPIOD_OUT_HIGH);
before it has been changed to the chunk above... So, yes, the DT flag
was not handled anyway...

Sorry for the noise and thanks for the clarification.

Bye,
--=20
Nicolas Ferre
