From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v8 2/3] net: hisilicon: new hip04 MDIO driver
Date: Mon, 21 Apr 2014 11:03:28 -0700
Message-ID: <CAGVrzcb8Ykxi72x3iBStjTL+OO1BhDc_yZnnPq8ZHra+mtrBEA@mail.gmail.com>
References: <1397869980-21187-1-git-send-email-zhangfei.gao@linaro.org>
 <1397869980-21187-3-git-send-email-zhangfei.gao@linaro.org> <53555C28.4050303@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>,
	David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Mark Rutland <mark.rutland@arm.com>,
	David Laight <David.Laight@aculab.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, xuwei5@hisilicon.com,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:42246 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753121AbaDUSEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 14:04:09 -0400
In-Reply-To: <53555C28.4050303@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-21 10:58 GMT-07:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
>
> On 04/19/2014 05:12 AM, Zhangfei Gao wrote:
>
>> Hisilicon hip04 platform mdio driver
>> Reuse Marvell phy drivers/net/phy/marvell.c
>
>
>> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
>
> [...]
>
>
>> diff --git a/drivers/net/ethernet/hisilicon/hip04_mdio.c
>> b/drivers/net/ethernet/hisilicon/hip04_mdio.c
>> new file mode 100644
>> index 0000000..19826a3
>> --- /dev/null
>> +++ b/drivers/net/ethernet/hisilicon/hip04_mdio.c
>> @@ -0,0 +1,185 @@
>> +
>
>
>    Empty line not needed here.
>
>
>> +/* Copyright (c) 2014 Linaro Ltd.
>> + * Copyright (c) 2014 Hisilicon Limited.
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms of the GNU General Public License as published by
>> + * the Free Software Foundation; either version 2 of the License, or
>> + * (at your option) any later version.
>> + */
>
>
> [...]
>
>
>> +static int hip04_mdio_reset(struct mii_bus *bus)
>> +{
>> +       int temp, err, i;
>> +
>> +       for (i = 0; i < PHY_MAX_ADDR; i++) {
>> +               hip04_mdio_write(bus, i, 22, 0);
>
>
>    Why? What kind of a register this is? <uapi/linux/mii.h> tells me it's
> MII_SREVISION...

I think this rather means clause 22 as opposed to clause 45.

>
>
>> +               temp = hip04_mdio_read(bus, i, MII_BMCR);
>
>
>    You're not checking for error...
>
>
>> +               temp |= BMCR_RESET;
>> +               err = hip04_mdio_write(bus, i, MII_BMCR, temp);
>
>
>    Hmm, why you're open coding BMCR reset? There's phy_init_hw() doing this
> correctly...

Except that this runs way before we have created the PHY driver, so we
can't use that function just yet. I already asked about this, and he
explained that this was because the PHY devices he uses are not
responding correcty to MII_PHYSID1/2 reads.

>
>
>> +               if (err < 0)
>> +                       return err;
>> +       }
>> +
>> +       mdelay(500);
>> +       return 0;
>> +}
>> +
>> +static int hip04_mdio_probe(struct platform_device *pdev)
>> +{
>> +       struct resource *r;
>> +       struct mii_bus *bus;
>> +       struct hip04_mdio_priv *priv;
>> +       int ret;
>> +
>> +       bus = mdiobus_alloc_size(sizeof(struct hip04_mdio_priv));
>> +       if (!bus) {
>> +               dev_err(&pdev->dev, "Cannot allocate MDIO bus\n");
>> +               return -ENOMEM;
>> +       }
>> +
>> +       bus->name = "hip04_mdio_bus";
>> +       bus->read = hip04_mdio_read;
>> +       bus->write = hip04_mdio_write;
>> +       bus->reset = hip04_mdio_reset;
>
>
>    Ah... However I don't think it a good implementation of that bus
> method...
>
> [...]
>
> WBR, Sergei
>



-- 
Florian
