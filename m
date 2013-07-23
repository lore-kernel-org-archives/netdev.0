From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 1/4] net: smsc911x: add support for a reset GPIO
Date: Tue, 23 Jul 2013 13:38:09 -0300
Message-ID: <CAOMZO5AzEgkyRz0N0a3CSS7sWEatT3ZQX9eku1fH6hzheh0ARA@mail.gmail.com>
References: <1374595924-12338-1-git-send-email-g.liakhovetski@gmx.de>
	<1374595924-12338-2-git-send-email-g.liakhovetski@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-sh@vger.kernel.org, Magnus Damm <magnus.damm@gmail.com>,
	Simon Horman <horms@verge.net.au>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	netdev@vger.kernel.org,
	Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1374595924-12338-2-git-send-email-g.liakhovetski@gmx.de>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 23, 2013 at 1:12 PM, Guennadi Liakhovetski
<g.liakhovetski@gmx.de> wrote:

> +       if (pdata->config.reset_gpio_config & SMSC911X_RESET_GPIO_VALID) {
> +               /* Take the chip out of hard reset */
> +               unsigned long flags = (pdata->config.reset_gpio_config ^
> +                                      GPIOF_INIT_HIGH) & 0xf;
> +               retval = gpio_request_one(pdata->config.reset_gpio,

If you use devm_gpio_request_one() here, then you can simplify your
code by not having to call gpio_free.
