From: Rojhalat Ibrahim <imr@rtschenk.de>
Subject: Re: [PATCH] mdio-mux-gpio: Use GPIO descriptor interface and new gpiod_set_array function
Date: Tue, 25 Nov 2014 09:13:48 +0100
Message-ID: <8914633.CtiBEziHQ6@pcimr>
References: <6441674.xrJo8HXDvD@pcimr> <CAAVeFuKTmQi3vK5vALbT=hseRm9mn=-cb-7hiHwg7Zbczmz_WA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Daney <david.daney@cavium.com>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <acourbot@nvidia.com>
To: Alexandre Courbot <gnurou@gmail.com>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <CAAVeFuKTmQi3vK5vALbT=hseRm9mn=-cb-7hiHwg7Zbczmz_WA@mail.gmail.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 25 November 2014 12:39:13 Alexandre Courbot wrote:
> On Thu, Nov 20, 2014 at 9:24 PM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:
> > @@ -70,20 +64,17 @@ static int mdio_mux_gpio_probe(struct platform_device *pdev)
> >         s->num_gpios = num_gpios;
> >
> >         for (n = 0; n < num_gpios; ) {
> > -               int gpio = of_get_gpio_flags(pdev->dev.of_node, n, &f);
> > -               if (gpio < 0) {
> > -                       r = (gpio == -ENODEV) ? -EPROBE_DEFER : gpio;
> > +               struct gpio_desc *gpio = gpiod_get_index(&pdev->dev,
> > +                                                        "mdio-mux-gpio", n);
> 
> Doesn't this change introduce some incompatibility against the current
> DT bindings? of_get_gpio_flags() looks for a "gpios" property, while
> your call to gpiod_get_index() will look for "mdio-mux-gpio-gpios". It
> should probably be changed to gpiod_get_index(&pdev->dev, NULL, n).
> 

You are right, of course. I'll fix it and post a new patch version.

> ... or even be changed to gpiod_get_index(&pdev->dev, NULL, n,
> GPIOD_OUT_LOW) as the calls to gpiod_get() functions are being updated
> to take an initial state (both variants are currently usable but the
> former one will disappear in the future). This will also allow you to
> get rid of your call to gpiod_direction_output().
> 

Will do that.

> Side-note: it would be nice to have a gpiod_get_array() call that does
> exactly what this loop does, and returns an array of gpios directly
> usable by gpiod_set_array*(). And a matching gpiod_put_array() of
> course.
> 

I'll add that to my to-do-list.


Thanks
   Rojhalat

