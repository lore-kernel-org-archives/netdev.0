From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH v2] net/phy: micrel: Add OF configuration support
Date: Thu, 1 Aug 2013 10:47:28 +0200
Message-ID: <20130801084728.GE26614@pengutronix.de>
References: <1375340034-23846-1-git-send-email-xobs@kosagi.com>
 <1375340034-23846-2-git-send-email-xobs@kosagi.com>
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
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33030 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753261Ab3HAIrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 04:47:36 -0400
Content-Disposition: inline
In-Reply-To: <1375340034-23846-2-git-send-email-xobs@kosagi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 01, 2013 at 06:53:54AM +0000, Sean Cross wrote:
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
>  .../devicetree/bindings/net/micrel-phy.txt         |   20 ++++++++
>  drivers/net/phy/micrel.c                           |   50 ++++++++++++++++++++
>  2 files changed, 70 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/micrel-phy.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/micrel-phy.txt b/Documentation/devicetree/bindings/net/micrel-phy.txt
> new file mode 100644
> index 0000000..97c1ef2
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/micrel-phy.txt
> @@ -0,0 +1,20 @@
> +Micrel KS8737, KSZ8041, KSZ8001, KS8721, KSZ8081, KSZ8091, KSZ8061, KSZ9021,
> +KSZ9031, Ethernet PHYs, and KSZ8873MLL and KSZ886X Ethernet switches.
> +
> +Some boards require special tuning values, particularly when it comes to
> +clock delays.  You can specify clock delay values by adding
> +micrel-specific properties to an Ethernet OF device node.
> +
> +Optional properties:
> +- micrel,clk-control-pad-skew : Timing offset for the MII clock line
> +- micrel,rx-data-pad-skew : Timing offset for the RX MII pad
> +- micrel,tx-data-pad-skew : Timing offset for the TX MII pad
> +
> +Example:
> +	&enet {
> +		micrel,clk-control-pad-skew = <0xf0f0>;
> +		micrel,rx-data-pad-skew = <0x0000>;
> +		micrel,tx-data-pad-skew = <0xffff>;
> +		status = "okay";
> +	};

Given that this patch adds a devicetree binding which I think we now
agree that this introduces an ABI I think this needs more thought. Some
questions:

- Does binding this also work for MII controllers external to the MAC?
  Several Marvell SoCs have this situation. MDIO is a bus. With the
  binding above you assume that all devices on the bus use the same
  settings
- You directly put the register contents into dt. This assumes that all
  micrel phys have a compatible register layout. This may be the case
  now, but what's with future phys?
- The pad skew settings are needed for other phys aswell. It might be
  worth introducing a binding which could work for say Artheros phys
  aswell.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
