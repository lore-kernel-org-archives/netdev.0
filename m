From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH RFT 2/2] macb: kill PHY reset code
Date: Tue, 12 Apr 2016 11:22:10 +0200
Message-ID: <570CBE42.50309@atmel.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <2811962.eGX2i5RJbZ@wasted.cogentembedded.com>
 <20160411022802.GB4307@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160411022802.GB4307@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 11/04/2016 04:28, Andrew Lunn a =E9crit :
> On Sat, Apr 09, 2016 at 01:25:03AM +0300, Sergei Shtylyov wrote:
>> With  the 'phylib' now  being aware of  the "reset-gpios" PHY node p=
roperty,
>> there should be no need to frob the PHY reset in this  driver anymor=
e...
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>
>> ---
>>  drivers/net/ethernet/cadence/macb.c |   17 -----------------
>>  drivers/net/ethernet/cadence/macb.h |    1 -
>>  2 files changed, 18 deletions(-)
>>
>> Index: net-next/drivers/net/ethernet/cadence/macb.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- net-next.orig/drivers/net/ethernet/cadence/macb.c
>> +++ net-next/drivers/net/ethernet/cadence/macb.c
>> @@ -2884,7 +2884,6 @@ static int macb_probe(struct platform_de
>>  					      =3D macb_clk_init;
>>  	int (*init)(struct platform_device *) =3D macb_init;
>>  	struct device_node *np =3D pdev->dev.of_node;
>> -	struct device_node *phy_node;
>>  	const struct macb_config *macb_config =3D NULL;
>>  	struct clk *pclk, *hclk =3D NULL, *tx_clk =3D NULL;
>>  	unsigned int queue_mask, num_queues;
>> @@ -2977,18 +2976,6 @@ static int macb_probe(struct platform_de
>>  	else
>>  		macb_get_hwaddr(bp);
>> =20
>> -	/* Power up the PHY if there is a GPIO reset */
>> -	phy_node =3D  of_get_next_available_child(np, NULL);
>> -	if (phy_node) {
>> -		int gpio =3D of_get_named_gpio(phy_node, "reset-gpios", 0);
>> -
>> -		if (gpio_is_valid(gpio)) {
>> -			bp->reset_gpio =3D gpio_to_desc(gpio);
>> -			gpiod_direction_output(bp->reset_gpio, 1);
>=20
> Hi Sergei
>=20
> The code you are deleting would of ignored the flags in the gpio

I don't parse this.

The code deleted does take the flag into account. And the DT property
associated to it seems correct to me (I mean, with proper flag
specification).

> property, i.e. active low. The new code in the previous patch does
> however take the flags into account. Did you check if there are any
> device trees which have flags, which were never used, but are now
> going to be used and thus break...

=46lag was used and you are saying that it's taken into account in new
code... So, what's the issue?

I see a difference in the way the "value" of gpiod_* functions is used.
There may be a misunderstanding here...

Bye,
--=20
Nicolas Ferre
