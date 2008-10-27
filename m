From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [PATCH] phylib: add mdio-gpio bus driver (v2)
Date: Mon, 27 Oct 2008 10:52:28 -0400
Message-ID: <8bd0f97a0810270752p5fb6e560m6ddcf07df8f689f5@mail.gmail.com>
References: <20081027105318.21923.24436.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org
To: "Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <20081027105318.21923.24436.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Content-Disposition: inline
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 27, 2008 at 06:53, Paulius Zaleckas wrote:
> +config MDIO_GPIO
> +       tristate "Support for GPIO bitbanged MDIO buses"
> +       depends on MDIO_BITBANG && GENERIC_GPIO
> +       help
> +         Supports MDIO busses connected to GPIO.

please add a line stating the name of the module if it is built as such

> +static struct mdiobb_ops mdio_gpio_ops = {
> +       .owner = THIS_MODULE,
> +       .set_mdc = mdc,
> +       .set_mdio_dir = mdio_dir,
> +       .set_mdio_data = mdio,
> +       .get_mdio_data = mdio_read,
> +};

shouldnt the function names match the gpio_ops ?  things like "mdc"
and "mdio" are a little obscure ...

> +static int __devinit mdio_gpio_probe(struct platform_device *pdev)
> +{
> +       struct mii_bus *new_bus;
> +       struct mdio_gpio_info *bitbang;
> +       struct mdio_gpio_platform_data *pdata;
> +       int ret = -ENOMEM;
> +       int i;
> +
> +       pdata = pdev->dev.platform_data;
> +       if (pdata == NULL)
> +               goto out;
> +
> +       bitbang = kzalloc(sizeof(struct mdio_gpio_info), GFP_KERNEL);

sizeof(*bitbang) tends to read better and be more resistant to bitrot

> +       if (gpio_request(bitbang->mdc, "mdc"))
> +               goto out_free_bitbang;
> +
> +       if (gpio_request(bitbang->mdio, "mdio"))
> +               goto out_free_mdc;

maybe include driver name and/or the platform id ?  if you have
multiple mdio-gpio's running at the same time, coordinating may get a
little messy ...

> +       new_bus->name = "GPIO Bitbanged MII",

platform id here too ?

> +static int mdio_gpio_init(void)
> +{
> +       return platform_driver_register(&mdio_gpio_driver);
> +}

needs __init markings

> +static void mdio_gpio_exit(void)
> +{
> +       platform_driver_unregister(&mdio_gpio_driver);
> +}

needs __exit markings
-mike
