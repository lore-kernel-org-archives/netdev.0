From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: phy: leds: Add support for "link" trigger
Date: Wed, 1 Nov 2017 13:16:11 +0100
Message-ID: <20171101121611.GD12680@lunn.ch>
References: <52ce25a6-8d6b-039d-ca08-90595eb9ee72@maciej.szmigiero.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
To: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52ce25a6-8d6b-039d-ca08-90595eb9ee72@maciej.szmigiero.name>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> @@ -123,6 +153,10 @@ int phy_led_triggers_register(struct phy_device *phy)
>  	while (i--)
>  		phy_led_trigger_unregister(&phy->phy_led_triggers[i]);
>  	devm_kfree(&phy->mdio.dev, phy->phy_led_triggers);
> +out_unreg_link:
> +	phy_led_trigger_unregister(phy->led_link_trigger);
> +out_free_link:
> +	devm_kfree(&phy->mdio.dev, phy->led_link_trigger);

Hi Maciej

The point of the devm_ API is that you don't need to worry about
freeing the memory. The core will do it, when the driver is removed.

I guess you are just copying the code above, which i would also say is
unnecessary.

	Andrew
