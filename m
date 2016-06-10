From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/5] net: dsa: b53: Add support for Broadcom
 RoboSwitch
Date: Fri, 10 Jun 2016 14:11:49 +0200
Message-ID: <20160610121149.GC2338@lunn.ch>
References: <1465521837-30193-1-git-send-email-f.fainelli@gmail.com>
 <1465521837-30193-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
	davem@davemloft.net, jon.mason@broadcom.com,
	hemal.shah@broadcom.com, bandaru.viswanath@broadcom.com,
	michael.chan@broadcom.com, jogo@openwrt.org, cphealy@gmail.com,
	ardeleanalex@gmail.com, jiri@mellanox.com, idosch@mellanox.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41472 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752970AbcFJMLx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 08:11:53 -0400
Content-Disposition: inline
In-Reply-To: <1465521837-30193-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static void b53_switch_reset_gpio(struct b53_device *dev)
> +{
> +	int gpio = dev->reset_gpio;
> +
> +	if (gpio < 0)
> +		return;
> +
> +	/* Reset sequence: RESET low(50ms)->high(20ms)
> +	 */
> +	gpio_set_value(gpio, 0);
> +	mdelay(50);
> +
> +	gpio_set_value(gpio, 1);
> +	mdelay(20);
> +
> +	dev->current_page = 0xff;
> +}

Hi Florian

It would be better to use the gpiod API here, so the active hi/active
low flag is respected.

> +	dev->reset_gpio = b53_switch_get_reset_gpio(dev);
> +	if (dev->reset_gpio >= 0) {
> +		ret = devm_gpio_request_one(dev->dev, dev->reset_gpio,
> +					    GPIOF_OUT_INIT_HIGH, "robo_reset");
> +		if (ret)
> +			return ret;
> +	}
> +
> +	return 0;
> +}

> +static inline int b53_switch_get_reset_gpio(struct b53_device *dev)
> +{
> +	enum bcm47xx_board board = bcm47xx_board_get();
> +
> +	switch (board) {
> +	case BCM47XX_BOARD_LINKSYS_WRT300NV11:
> +	case BCM47XX_BOARD_LINKSYS_WRT310NV1:
> +		return 8;

Rather than hard coding it, could we get it from device tree?

       Andrew
