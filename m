From: Juergen Borleis <jbe@pengutronix.de>
Subject: Re: [PATCH 3/4] net: dsa: LAN9303: add I2C managed mode support
Date: Thu, 6 Apr 2017 15:46:03 +0200
Message-ID: <201704061546.04478.jbe@pengutronix.de>
References: <20170405092024.16048-1-jbe@pengutronix.de> <20170405092024.16048-4-jbe@pengutronix.de> <20170405182155.GF21965@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:39379 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933709AbdDFNqm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 09:46:42 -0400
In-Reply-To: <20170405182155.GF21965@lunn.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Wednesday 05 April 2017 20:21:55 Andrew Lunn wrote:
> [...]
> > +SMSC/MicroChip LAN9303 three port ethernet switch
> > +-------------------------------------------------
> > +
> > +Required properties:
> > +
> > +- compatible: should be "smsc,lan9303"
> > +- #size-cells: must be 0
> > +- #address-cells: must be 1
> > +
> > +Optional properties:
> > +
> > +- phy-reset-gpios: GPIO to be used to reset the whole device, always low active
> > +- phy-reset-duration: reset duration, defaults to 200 ms 
>
> It is good to state the unit, ms.

Done in v2.

> [...]
> > +	master: masterdevice@X {
> > +		phy-handle = <&ethphy>;
> > +		status = "okay";
> > +
> > +		mdio {
> > +			#address-cells = <1>;
> > +			#size-cells = <0>;
> > +
> > +			ethphy: ethernet-phy@0 {
> > +				compatible = "ethernet-phy-ieee802.3-c22";
> > +				reg = <0>;
> > +				max-speed = <100>;
> > +			};
>
> If there is RMII between the CPU interface and the switch, why is this
> PHY needed?

Tested and changed to "fixed-link" in v2.

> [...]
> > +	switch: switch@a {
> > +		compatible = "smsc,lan9303";
> > +		reg = <0xa>;
> > +		status = "okay";
> > +		interrupts-extended = <&gpio2 7 IRQ_TYPE_LEVEL_LOW>;
>
> This interrupt is not in the binding documentation, or the code.

Leftover from development. Removed in v2.

> > +		phy-reset-gpios = <&gpio7 6 GPIO_ACTIVE_LOW>;
> > +		phy-reset-duration = <200>;
> > +
> > +		dsa,member = <0 0>;
> > +
> > +		ports {
> > +			#address-cells = <1>;
> > +			#size-cells = <0>;
> > +
> > +			port@0 { /* RMII fixed link to master */
> > +				reg = <0>;
> > +				label = "cpu";
> > +				ethernet = <&master>;
> > +				max-speed = <100>;
>
> max-speed does not do anything i think, since there is no adjust_link
> function.

Removed in v2.

Thanks.

Juergen

-- 
Pengutronix e.K.                             | Juergen Borleis             |
Industrial Linux Solutions                   | http://www.pengutronix.de/  |
