From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Tue, 18 Jul 2017 15:32:09 +0200
Message-ID: <20170718133209.GB32757@lunn.ch>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com>
 <6f984a9c-e6d3-fd0a-6719-fa9032d43d1d@cogentembedded.com>
 <CAOMZO5ABD9iasv67ehcpTzcjU-iD9=8vQ2vM7Gwc4-v9pnUt-Q@mail.gmail.com>
 <f4cdcb4b-feac-5106-8068-e694dbd3b4e6@cogentembedded.com>
 <CAOMZO5BycGHNocULcScDczRoEvbQqjnRZTDrNAw7=+zpadSOSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>
To: Fabio Estevam <festevam@gmail.com>,
        Linus Walleij <linus.walleij@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59360 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751396AbdGRNcR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Jul 2017 09:32:17 -0400
Content-Disposition: inline
In-Reply-To: <CAOMZO5BycGHNocULcScDczRoEvbQqjnRZTDrNAw7=+zpadSOSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 18, 2017 at 09:52:51AM -0300, Fabio Estevam wrote:
> On Tue, Jul 18, 2017 at 9:48 AM, Sergei Shtylyov
> <sergei.shtylyov@cogentembedded.com> wrote:
> > On 07/18/2017 03:39 PM, Fabio Estevam wrote:
> >
> >>>    Won't this result in kernel WARNING when GPIO is disabled?
> >
> >
> >    GPIO support, I was going to type...
> >
> >> Not sure if I understood your point, but gpiod_set_value_cansleep() is
> >> a no-op when the gpiod is NULL.
> >
> >
> >    Look at the stub in <linux/gpio/consumer.h>, it has WARN_ON(1).
> 
> This patch does not alter the behavior of the driver with respect to
> GPIO being disabled, so I still do not understand your concern.

http://elixir.free-electrons.com/linux/latest/source/include/linux/gpio/consumer.h#L345
static inline void gpiod_set_value_cansleep(struct gpio_desc *desc, int value)
{
	/* GPIO can never have been requested */
	WARN_ON(1);
}

But i would say this is a gpio problem. If GPIO enabled does not care,
GPIO disabled should also not care.

Adding Linus Walleij.

     Andrew
