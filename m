From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH v5] net/phy: micrel: Add OF configuration support for
 ksz9021
Date: Tue, 20 Aug 2013 11:17:20 +0200
Message-ID: <20130820091719.GA31024@pengutronix.de>
References: <1375686248-17995-1-git-send-email-xobs@kosagi.com>
 <1375686248-17995-2-git-send-email-xobs@kosagi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Duan Fugang-B38611 <B38611@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Steven Rostedt <rostedt@goodmis.org>
To: Sean Cross <xobs@kosagi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53751 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751Ab3HTJRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 05:17:25 -0400
Content-Disposition: inline
In-Reply-To: <1375686248-17995-2-git-send-email-xobs@kosagi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 05, 2013 at 07:04:08AM +0000, Sean Cross wrote:
> Some boards require custom PHY configuration, for example due to trace
> length differences.  Add the ability to configure these registers in
> order to get the PHY to function on boards that need it.
> 
> Because PHYs are auto-detected based on MDIO device IDs, allow PHY
> configuration to be specified in the parent Ethernet device node if no
> PHY device node is present.
> 
> Signed-off-by: Sean Cross <xobs@kosagi.com>
> ---
>  .../devicetree/bindings/net/micrel-ksz9021.txt     |   49 ++++++++++
>  drivers/net/phy/micrel.c                           |  101 +++++++++++++++++++-
>  2 files changed, 149 insertions(+), 1 deletion(-)
>  create mode 100644 Documentation/devicetree/bindings/net/micrel-ksz9021.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/micrel-ksz9021.txt b/Documentation/devicetree/bindings/net/micrel-ksz9021.txt
> new file mode 100644
> index 0000000..338a7e2
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/micrel-ksz9021.txt
> @@ -0,0 +1,49 @@
> +Micrel KSZ9021 Gigabit Ethernet PHY
> +
> +Some boards require special tuning values, particularly when it comes to
> +clock delays.  You can specify clock delay values by adding
> +micrel-specific properties to an Ethernet OF device node.
> +
> +All skew control options are specified in picoseconds.  The minimum
> +value is 0, and the maximum value is 3000.
> +
> +Optional properties:
> + - rxc-skew : Skew control of RXC pad
> + - rxdv-skew : Skew control of RX CTL pad
> + - txc-skew : Skew control of TXC pad
> + - txen-skew : Skew control of TX_CTL pad
> + - rxd0-skew : Skew control of RX data 0 pad
> + - rxd1-skew : Skew control of RX data 1 pad
> + - rxd2-skew : Skew control of RX data 2 pad
> + - rxd3-skew : Skew control of RX data 3 pad
> + - txd0-skew : Skew control of TX data 0 pad
> + - txd1-skew : Skew control of TX data 1 pad
> + - txd2-skew : Skew control of TX data 2 pad
> + - txd3-skew : Skew control of TX data 3 pad
> +
> +Examples:
> +
> +	/* Attach to an Ethernet device with autodetected PHY */
> +	&enet {
> +		rxc-skew = <3000>; // picoseconds
> +		rxdv-skew = <0>;   // picoseconds
> +		txc-skew = <3000>; // picoseconds
> +		txen-skew = <0>;   // picoseconds

I prefer to add a -ps suffix to the property names. This makes the
comments unnecessary and provides the unit information automatically
where it is needed.

> +	if (val1 != -1)
> +		newval = ((newval & 0xfff0) | ((val1/200)&0xf) << 0);

Please add whitespaces at both sides os operators as required in
Documentation/CodingStyle.

Otherwise:

Reviewed-by: Sascha Hauer <s.hauer@pengutronix.de>

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
