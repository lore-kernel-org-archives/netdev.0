From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH net-next 1/2] net: dsa: Add support for a switch reset
 gpio
Date: Thu, 19 Nov 2015 09:39:11 +0100
Message-ID: <564D8AAF.6060901@baylibre.com>
References: <1447889365-25256-1-git-send-email-andrew@lunn.ch>
 <1447889365-25256-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:33345 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754016AbbKSIjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 03:39:31 -0500
Received: by wmec201 with SMTP id c201so13754848wme.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 00:39:30 -0800 (PST)
In-Reply-To: <1447889365-25256-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On 11/19/2015 12:29 AM, Andrew Lunn wrote:
> +		gpio = of_get_named_gpio_flags(child, "reset-gpios", 0,
> +					       &flags);
> +		if (gpio_is_valid(gpio)) {
> +			ret = devm_gpio_request_one(dev, gpio, flags,
> +						    "switch_reset");
> +			if (ret)
> +				goto out_free_chip;
> +
> +			cd->reset = gpio;
> +			cd->reset_flags = flags;
> +			off = (flags && OF_GPIO_ACTIVE_LOW ? 1 : 0);
> +			gpio_direction_output(cd->reset, off);
> +		}
> +
>  		for_each_available_child_of_node(child, port) {
>  			port_reg = of_get_property(port, "reg", NULL);
>  			if (!port_reg)
> 

You could also use :
gpio = of_get_named_gpio(child, "reset-gpios", 0)
devm_gpio_request(dev, gpio, "switch_reset")

and :
cd->reset = gpio_to_desc(gpio);

and cd->switch reset to struct gpio_desc *reset

to use the gpiod calls afterward. The flags are no more needed.

Neil
