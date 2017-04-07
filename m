From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 3/4] net: dsa: LAN9303: add I2C managed mode support
Date: Fri, 7 Apr 2017 15:40:07 +0200
Message-ID: <20170407134007.GA22263@lunn.ch>
References: <20170407081502.30172-1-jbe@pengutronix.de>
 <20170407081502.30172-4-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170407081502.30172-4-jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Juergen

> +Optional properties:
> +
> +- reset-gpios: GPIO to be used to reset the whole device, always low active

I would avoid the always low active comment. The input to the switch
is active low. But i've seen designs with an inverter in the reset
path, so from the perspective of the GPIO it would be active high. The
device tree binding allows for this, via the flags. And since you use
the gpiod API, it should all just work.

> +		ports {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +
> +			port@0 { /* RMII fixed link to master */
> +				reg = <0>;
> +				label = "cpu";
> +				ethernet = <&master>;
> +			};
> +
> +			port@1 { /* external port 1 */
> +				compatible = "ethernet-phy-ieee802.3-c22";
> +				reg = <1>;
> +				label = "lan1;
> +			};

These are not PHY nodes, so does this compatible string do anything?

      Andrew
