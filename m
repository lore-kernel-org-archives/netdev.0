From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [RFC PATCH] dt-binding: net: sfp binding documentation
Date: Mon, 21 Aug 2017 13:53:17 +0100
Message-ID: <20170821125317.GS20805@n2100.armlinux.org.uk>
References: <d73b635069a2054d110632f1f4196cd4bc281e7f.1503224886.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:51452 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752234AbdHUMxf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 08:53:35 -0400
Content-Disposition: inline
In-Reply-To: <d73b635069a2054d110632f1f4196cd4bc281e7f.1503224886.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 20, 2017 at 01:28:06PM +0300, Baruch Siach wrote:
> Add device-tree binding documentation SFP transceivers. Support for SFP
> transceivers has been recently introduced (drivers/net/phy/sfp.c).
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> ---
> 
> The SFP driver is on net-next.
> 
> Not sure about the rate-select-gpio property name. The SFP+ standard
> (not supported yet) uses two signals, RS0 and RS1. RS0 is compatible
> with the SFP rate select signal, while RS1 controls the Tx rate.

SFP+ is usable with this, but the platforms I have do not wire the
rate select pins on the SFP+ sockets to GPIOs, but hard-wire them.

Note that I didn't expect the SFP code to just get merged with very
little in the way of real in-depth review of things like:

* the way the SFP code works, and its structure
* analysis of the bindings checking that they're fit for everyone's
  purposes.

The implementation that I've designed is based around the boards that
I have access to and the various public SFP documentation.  I think
documenting the bindings suggests that they are stable - I don't think
we're really ready to make that assertion yet - there may be things
that have been missed which will only come up when other people start
using this code.

> ---
>  Documentation/devicetree/bindings/net/sff-sfp.txt | 24 +++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/sff-sfp.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/sff-sfp.txt b/Documentation/devicetree/bindings/net/sff-sfp.txt
> new file mode 100644
> index 000000000000..f0c27bc3925e
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/sff-sfp.txt
> @@ -0,0 +1,24 @@
> +Small Form Factor (SFF) Committee Small Form-factor Pluggable (SFP)
> +Transceiver
> +
> +Required properties:
> +
> +- compatible : must be "sff,sfp"
> +
> +Optional Properties:
> +
> +- i2c-bus : phandle of an I2C bus controller for the SFP two wire serial
> +  interface

The code as it currently stands pretty much requires an I2C bus to be
functional - but when I wrote the code, I left the possibility open for
an implementation (eg, network driver) to provide its own functionality
for reading the I2C EEPROM on the module.  Some adapters which already
have SFP support do this.

Hence, for current implementations, this is required.

> +
> +- moddef0-gpio : phandle of the MOD-DEF0 (AKA Mod_ABS) module presence input
> +  gpio signal
> +
> +- los-gpio : phandle of the Receiver Loss of Signal Indication input gpio
> +  signal
> +
> +- tx-fault-gpio : phandle of the Module Transmitter Fault input gpio signal
> +
> +- tx-disable-gpio : phandle of the Transmitter Disable output gpio signal
> +
> +- rate-select-gpio : phandle of the Rx Signaling Rate Select (AKA RS0) output
> +  gpio
> -- 
> 2.14.1
> 

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
