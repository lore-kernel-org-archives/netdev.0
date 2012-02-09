From: Andy Fleming <afleming@gmail.com>
Subject: Re: newbie: phy platform interrupt config
Date: Thu, 9 Feb 2012 00:29:15 -0600
Message-ID: <CAKWjMd66rTzM7AipQZsu-c0jDSNw_=CFHnN1Mms4WQp_4aaFWA@mail.gmail.com>
References: <201201241537.17194.tim01@iss.tu-darmstadt.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	Richard Cochran <richard.cochran@omicron.at>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Decotigny <decot@google.com>,
	linux-kernel@vger.kernel.org
To: Tim Sander <tim01@iss.tu-darmstadt.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201201241537.17194.tim01@iss.tu-darmstadt.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 24, 2012 at 8:37 AM, Tim Sander <tim01@iss.tu-darmstadt.de> wrote:
> Hi
>
> I would like to set the interrupt for the phy on the i.mx35 pcm43 in the file
> arch/arm/mach-imx/mach-pcm043.c. Unfortunatly i didn't find a way to specify
> it. So i want to set the field (struct phy_device*)->irq.
>
> What i managed so far is to request the gpio for the interrupt:
> #define IMX_PHY_IRQ IMX_GPIO_NR(2,7)
> gpio_request(IMX_PHY_IRQ, "FEC PHY irq");
> gpio_direction_input(IMX_PHY_IRQ);
>
> Now i guess the result of "gpio_to_irq(IMX_PHY_IRQ)" should go into some kind
> of argument to imx35_add_fec(pdata) which is a macro
> imx_add_fec(&imx35_fec_data, pdata).
> pdata is of type (?) struct fec_platform_data which contains phy_interface_t
> and unsigned char array. So i don't see a way to set the phy interrupt there.
>
> I tried search for a driver which set the phy irq but i didn't find any and
> setting the phy in the phy_fixup function is also not working since the
> interrupt seems not get registered when opening the device.
>
> So how do i set the phy interrupt line in the platform file?

Look in drivers/of/of_mdio.c.

It's the job of the mdio driver to set the IRQs for the device. I
don't honestly know why I designed it that way. I suspect it's because
the MDIO controller's driver is the entity most likely to communicate
directly with the platform code.

So wherever you set up your mdio bus, set the IRQs for all the PHYs on
the bus there.

Andy
