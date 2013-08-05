From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH v3] net/phy: micrel: Add OF configuration support for
 ksz9021
Date: Mon, 5 Aug 2013 01:58:37 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE015ED2F7@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1375348757-12856-1-git-send-email-xobs@kosagi.com>
 <1375348757-12856-2-git-send-email-xobs@kosagi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Steven Rostedt <rostedt@goodmis.org>
To: Sean Cross <xobs@kosagi.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe003.messaging.microsoft.com ([216.32.180.186]:21786
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754141Ab3HEB6s convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Aug 2013 21:58:48 -0400
In-Reply-To: <1375348757-12856-2-git-send-email-xobs@kosagi.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Cross [mailto:xobs@kosagi.com]
Data: Thursday, August 01, 2013 5:19 PM

> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/micrel-ksz9021.txt
> @@ -0,0 +1,19 @@
> +Micrel KSZ9021 Gigabit Ethernet PHY
> +
> +Some boards require special tuning values, particularly when it comes
> +to clock delays.  You can specify clock delay values by adding
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
> +

The phy binding must be the phy node, not the ethernet node.
Pls refer to:  
		  Documentation/devicetree/booting-without-of.txt
		  Documentation/devicetree/bindings/net/phy.txt
	

> +static int ksz9021_config_init(struct phy_device *phydev) {
> +	struct device *dev = &phydev->dev;
> +	struct device_node *of_node = dev->of_node;
> +
> +	if (!of_node && dev->parent->of_node)
> +		of_node = dev->parent->of_node;
> +
If phy binding is phy node, there only check of_node, don't re-evaluate the phy node.

Thanks,
Andy
