From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [PATCH] phylib: add mdio-gpio bus driver (v2)
Date: Tue, 28 Oct 2008 10:30:39 +0200
Message-ID: <4906CDAF.2070000@teltonika.lt>
References: <20081027105318.21923.24436.stgit@Programuotojas.82-135-208-232.ip.zebra.lt> <8bd0f97a0810270752p5fb6e560m6ddcf07df8f689f5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <8bd0f97a0810270752p5fb6e560m6ddcf07df8f689f5@mail.gmail.com>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for review. Comments below.

Mike Frysinger wrote:
> On Mon, Oct 27, 2008 at 06:53, Paulius Zaleckas wrote:

[...]

>> +static int __devinit mdio_gpio_probe(struct platform_device *pdev)
>> +{
>> +       struct mii_bus *new_bus;
>> +       struct mdio_gpio_info *bitbang;
>> +       struct mdio_gpio_platform_data *pdata;
>> +       int ret = -ENOMEM;
>> +       int i;
>> +
>> +       pdata = pdev->dev.platform_data;
>> +       if (pdata == NULL)
>> +               goto out;
>> +
>> +       bitbang = kzalloc(sizeof(struct mdio_gpio_info), GFP_KERNEL);
> 
> sizeof(*bitbang) tends to read better and be more resistant to bitrot
> 
>> +       if (gpio_request(bitbang->mdc, "mdc"))
>> +               goto out_free_bitbang;
>> +
>> +       if (gpio_request(bitbang->mdio, "mdio"))
>> +               goto out_free_mdc;
> 
> maybe include driver name and/or the platform id ?  if you have
> multiple mdio-gpio's running at the same time, coordinating may get a
> little messy ...

Well... this is mostly for debugging only... I don't like the idea
to add additional char[..] variable and use sprintf...
IMO this would be just a bloat...

>> +       new_bus->name = "GPIO Bitbanged MII",
> 
> platform id here too ?

If you take a look one line below you would see that bus ID is formed
using platform id. Does this really need to be duplicated also in the
name?

>> +static int mdio_gpio_init(void)
>> +{
>> +       return platform_driver_register(&mdio_gpio_driver);
>> +}
> 
> needs __init markings
> 
>> +static void mdio_gpio_exit(void)
>> +{
>> +       platform_driver_unregister(&mdio_gpio_driver);
>> +}
> 
> needs __exit markings
> -mike
> 
