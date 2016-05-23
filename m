From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: Crashes in -next due to 'phy: add support for a reset-gpio
 specification'
Date: Sun, 22 May 2016 18:06:24 -0700
Message-ID: <57425790.3010902@roeck-us.net>
References: <573BF177.6090507@roeck-us.net>
 <20160522101051.GA23704@pengutronix.de> <5741D323.8010509@roeck-us.net>
 <20160522182112.GC23704@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Walleij <linus.walleij@linaro.org>,
	linux-gpio@vger.kernel.org
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160522182112.GC23704@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2016 11:21 AM, Uwe Kleine-K=F6nig wrote:
> Hello Guenter,
>
> [extending Cc: a bit]
>
> On Sun, May 22, 2016 at 08:41:23AM -0700, Guenter Roeck wrote:
>> On 05/22/2016 03:10 AM, Uwe Kleine-K=F6nig wrote:
>>> On Tue, May 17, 2016 at 09:37:11PM -0700, Guenter Roeck wrote:
>>>> [    9.366256] libphy: ethoc-mdio: probed
>>>> [    9.367389]  (null): could not attach to PHY
>>>> [    9.368555]  (null): failed to probe MDIO bus
>>>> [    9.371540] Unable to handle kernel paging request at virtual a=
ddress 0000001c
>>>> [    9.371540]  pc =3D d0320926, ra =3D 903209d1
>>>> [    9.375358] Oops: sig: 11 [#1]
>>>> [    9.376081] PREEMPT
>>>> [    9.377080] CPU: 0 PID: 1 Comm: swapper Not tainted 4.6.0-next-=
20160517 #1
>>>> [    9.378397] task: d7c2c000 ti: d7c30000 task.ti: d7c30000
>>>> [    9.379394] a00: 903209d1 d7c31bd0 d7fb5810 00000001 00000000 0=
0000000 d7f45c00 d7c31bd0
>>>> [    9.382298] a08: 00000000 00000000 00000000 00000000 00060100 d=
04b0c10 d7f45dfc d7c31bb0
>>>> [    9.385732] pc: d0320926, ps: 00060110, depc: 00000018, excvadd=
r: 0000001c
>>>> [    9.387061] lbeg: d0322e35, lend: d0322e57 lcount: 00000000, sa=
r: 00000011
>>>> [    9.388173]
>>>> Stack: d7c31be0 00060700 d7f45c00 d7c31bd0 9021d509 d7c31c30 d7f45=
c00 00000000
>>>>         d0485dcc d0485dcc d7fb5810 d7c2c000 00000000 d7c31c30 d7f4=
5c00 d025befc
>>>>         d0485dcc d7c30000 d7f45c34 d7c31bf0 9021c985 d7c31c50 d7f4=
5c00 d7f45c34
>>>> [    9.396652] Call Trace:
>>>> [    9.397469]  [<d021d4d9>] __device_release_driver+0x7d/0x98
>>>> [    9.398869]  [<d021d509>] device_release_driver+0x15/0x20
>>>> [    9.400247]  [<d021c985>] bus_remove_device+0xc1/0xd4
>>>> [    9.401569]  [<d021a935>] device_del+0x109/0x15c
>>>> [    9.402794]  [<d025c3f9>] phy_mdio_device_remove+0xd/0x18
>>>> [    9.404124]  [<d025d264>] mdiobus_unregister+0x40/0x5c
>>>> [    9.405444]  [<d025ff44>] ethoc_probe+0x534/0x5b8
>>>> [    9.406742]  [<d021e2e0>] platform_drv_probe+0x28/0x48
>>>> [    9.408122]  [<d021d1e5>] driver_probe_device+0x101/0x234
>>>> [    9.409499]  [<d021d395>] __driver_attach+0x7d/0x98
>>>> [    9.410809]  [<d021bd80>] bus_for_each_dev+0x30/0x5c
>>>> [    9.412104]  [<d021cdf0>] driver_attach+0x14/0x18
>>>> [    9.413385]  [<d021ca61>] bus_add_driver+0xc9/0x198
>>>> [    9.414686]  [<d021d7d4>] driver_register+0x70/0xa0
>>>> [    9.416001]  [<d021e2b4>] __platform_driver_register+0x24/0x28
>>>> [    9.417463]  [<d04a1d34>] ethoc_driver_init+0x10/0x14
>>>> [    9.418824]  [<d00032c8>] do_one_initcall+0x80/0x1ac
>>>> [    9.420083]  [<d049386d>] kernel_init_freeable+0x131/0x198
>>>> [    9.421504]  [<d03236e8>] kernel_init+0xc/0xb0
>>>> [    9.422693]  [<d000482c>] ret_from_kernel_thread+0x8/0xc
>>>
>>> Guenter, can you please test if the following patch fixes your setu=
p:
>>>
>>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_dev=
ice.c
>>> index 307f72a0f2e2..efa85fb31574 100644
>>> --- a/drivers/net/phy/phy_device.c
>>> +++ b/drivers/net/phy/phy_device.c
>>> @@ -1573,14 +1573,14 @@ static int phy_probe(struct device *dev)
>>>   	int err =3D 0;
>>>   	struct gpio_descs *reset_gpios;
>>>
>>> -	phydev->drv =3D phydrv;
>>> -
>>>   	/* take phy out of reset */
>>>   	reset_gpios =3D devm_gpiod_get_array_optional(dev, "reset",
>>>   						    GPIOD_OUT_LOW);
>>>   	if (IS_ERR(reset_gpios))
>>>   		return PTR_ERR(reset_gpios);
>>>
>>> +	phydev->drv =3D phydrv;
>>> +
>>>   	/* Disable the interrupt if the PHY doesn't support it
>>>   	 * but the interrupt is still a valid one
>>>   	 */
>>>
>>> This doesn't make your ethernet work, but at least the driver shoul=
d
>>> fail in a clean way.
>>>
>> I tried, but it still fails with exactly the same error, meaning
>> it still crashes with the same traceback.
>
> This is strange. If probe fails the device should stay unbound and it
> shouldn't enter the if block in __device_release_driver at all.
>
>>> Together with enabling GPIOLIB this should put ethernet in a workin=
g
>>> state again.
>>>
>>
>> I am not exactly in favor of forcing GPIOLIB to be enabled for every
>> system with Ethernet support, just because a few of them may require
>> a gpio based phy reset. The same is true, really, for every other
>> driver using _optional gpiolib functions.
>>
>> Personally, I think that the _optional functions in gpiolib _should_
>> return no error if gpiolib is not configured. After all, those
>> gpio pins _are_ supposed to be optional. gpiolib should be enabled
>> for affected configurations, ie on systems with gpio support which
>> do need the optional gpio pins. Forcing gpiolib to be enabled even
>> in systems with no gpio support seems to be a bit heavy-handed.
>> It just bloats the kernel on such systems with no added benefit.
>
> That's wrong. The usage of gpio_get_optional and friends means that t=
he
> gpio is optional for the *driver*, that is there are devices that mak=
e
> use of said gpio and others don't. For the devices where the gpio is
> specified its usage is not optional. So it must not be ignored e.g. b=
y
> GPIOLIB=3Dn configurations. IMHO the best would be to unconditionally

Hi Uwe,

I understand what you are saying, I just have a different perspective.
 From your point of view, you consider it unacceptable if optional GPIO
pins are made unavailable by changing the configuration to GPIOLIB=3Dn.
Ok, but that position has number of drawbacks.

Playing the system this way only works if the optional GPIO pins
are the only GPIO pins in use by the system. In almost all cases, this
will not be the case. Disabling GPIOLIB in systems really needing it
is simply not a realistic option.

As such, disabling GPIOLIB to "disable" optional GPIO pins is in most c=
ases
quite heavy-handed. Whoever wants to "disable" those optional pins can =
simply
disable them by removing the respective lines from the devicetree file,
or from the ACPI DSDT. Much easier to do, with less side effects.

So, in summary, the current approach of mandating that GPIOLIB=3Dy to b=
e able
to use drivers with optional GPIO pins only has the effect of unnecessa=
rily
increasing the code size for platforms with no GPIO support. Nothing el=
se.
It doesn't prevent users from "disabling" optional GPIO pins. There are=
 other
means to do that, from manipulating the devicetree file to manipulating
the DSDT to disabling ACPI (yes, that works too).

On top of all that, why would anyone want to play the game of "disablin=
g"
optional GPIO pins in the first place ? The only reason I can think of =
is
to reduce the code size by disabling GPIOLIB, but as already mentioned
that would in almost all cases result in failures all over the place -
systems using GPIO don't usually just use drivers with optional GPIO pi=
ns.

Plus, even if that is the intended use case, its use is inconsistent.
Users can still disable ACPI, and gpiolib is perfectly happy with it, e=
ven
if the system technically supports ACPI and its DSDT has entries for op=
tional
GPIO pins.

> enable that part of GPIOLIB such that the _optional variants do the
> following with GPIOLIB=3Dn:
>
> 	if a GPIO is specified:
> 		return -ENOSYS
> 	else:
> 		return NULL
>

Sure. I thought about it, and had a brief look into the gpiolib code. I=
t would
require a substantial part of the gpiolib code to be enabled, and as me=
ntioned
it would still be inconsistent as it really only applies to devicetree =
and
lookup table based configurations, but not to ACPI.

The potential gain of ensuring that GPIOLIB is not accidentally disable=
d
just doesn't seem to be worth the effort and the cost, at least not to =
me.
Any platform which needs GPIOLIB should just have and keep it enabled,
and I don't really see it as such a big deal to expect users to keep th=
at
in mind.

On the other side, I do dislike the notion of enforcing GPIOLIB=3Dy jus=
t because
some driver(s) used by a platform use optional gpio pins.

I understand that the current approach is what it is. I just don't agre=
e with it,
and I don't think it is particularly useful or beneficial. But it isn't=
 really
worth arguing about either, so let's just agree to disagree.

Thanks,
Guenter
