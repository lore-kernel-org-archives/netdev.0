From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH v5] net/phy: micrel: Add OF configuration support for
 ksz9021
Date: Mon, 5 Aug 2013 07:41:11 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE015EECA0@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1375686248-17995-1-git-send-email-xobs@kosagi.com>
 <1375686248-17995-2-git-send-email-xobs@kosagi.com>
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
Received: from [213.199.154.251] ([213.199.154.251]:33852 "EHLO
	db9outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754903Ab3HEHmq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 03:42:46 -0400
In-Reply-To: <1375686248-17995-2-git-send-email-xobs@kosagi.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Cross [mailto:xobs@kosagi.com]
Data: Monday, August 05, 2013 3:04 PM
> To: Sascha Hauer; Duan Fugang-B38611; netdev@vger.kernel.org;
> devicetree@vger.kernel.org
> Cc: David Miller; stephen@networkplumber.org; Steven Rostedt; Sean Cross
> Subject: [PATCH v5] net/phy: micrel: Add OF configuration support for
> ksz9021
> 
> Some boards require custom PHY configuration, for example due to trace
> length differences.  Add the ability to configure these registers in order
> to get the PHY to function on boards that need it.
> 
> Because PHYs are auto-detected based on MDIO device IDs, allow PHY
> configuration to be specified in the parent Ethernet device node if no PHY
> device node is present.
> 
> Signed-off-by: Sean Cross <xobs@kosagi.com>
> ---
> +static int ksz9021_load_values_from_of(struct phy_device *phydev,
> +				       struct device_node *of_node, u16 reg,
> +				       char *field1, char *field2,
> +				       char *field3, char *field4)
> +{
> +	int val1 = -1;
> +	int val2 = -2;
> +	int val3 = -3;
> +	int val4 = -4;
> +	int newval;
> +	int matches = 0;
> +
> +	if (!of_property_read_u32(of_node, field1, &val1))
> +		matches++;
> +
> +	if (!of_property_read_u32(of_node, field2, &val2))
> +		matches++;
> +
> +	if (!of_property_read_u32(of_node, field3, &val3))
> +		matches++;
> +
> +	if (!of_property_read_u32(of_node, field4, &val4))
> +		matches++;
> +
> +	if (!matches)
> +		return 0;
> +
> +	if (matches < 4)
> +		newval = kszphy_extended_read(phydev, reg);
> +	else
> +		newval = 0;
> +
> +	if (val1 != -1)
> +		newval = ((newval & 0xfff0) | ((val1/200)&0xf) << 0);
> +
> +	if (val2 != -1)
> +		newval = ((newval & 0xff0f) | ((val2/200)&0xf) << 4);
Must be :  Newval |= ...
> +
> +	if (val3 != -1)
> +		newval = ((newval & 0xf0ff) | ((val3/200)&0xf) << 8);
Must be :  Newval |= ...
> +
> +	if (val4 != -1)
> +		newval = ((newval & 0x0fff) | ((val4/200)&0xf) << 12);
Must be :  Newval |= ...
> +
> +	return kszphy_extended_write(phydev, reg, newval); }
