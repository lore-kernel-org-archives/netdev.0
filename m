From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 1/3] ethtool: Add link down reason callback
Date: Wed, 21 Jun 2017 15:58:09 +0200
Message-ID: <20170621135809.GC27585@lunn.ch>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
 <1498050286-17141-2-git-send-email-galp@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Gal Pressman <galp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58656 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751754AbdFUN6N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 09:58:13 -0400
Content-Disposition: inline
In-Reply-To: <1498050286-17141-2-git-send-email-galp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +enum {
> +	ETHTOOL_LINK_VENDOR_SPECIFIC = -1, /* Vendor specific issue provided in vendor_reason */
> +	ETHTOOL_LINK_NO_ISSUE, /* No issue observed with link */
> +	ETHTOOL_LINK_REASON_UNKNOWN, /* Unknown reason */

I think OTHER would be better that UNKNOWN. 

> +	ETHTOOL_LINK_NETDEV_CARRIER_DOWN, /* Netdev carrier is down */
> +	ETHTOOL_LINK_ADMIN_DOWN, /* Admin down */

These two are interesting. We have that information already. Why do we
want it again?

> +	ETHTOOL_LINK_AN_FAILED, /* Auto negotiation failed */
> +	ETHTOOL_LINK_TRAINING_FAILED, /* Link training failed */
> +	ETHTOOL_LINK_RMT_FAULT, /* Remote fault indication */
> +	ETHTOOL_LINK_BAD_SIGNAL_INTEGRITY, /* Bad signal integrity */
> +	ETHTOOL_LINK_CABLE_MISMATCH, /* Cable protocol mismatch */
> +	ETHTOOL_LINK_INTERNAL_ERR, /* Internal error */

How does an internet error differ from an UNKNOWN?

> +	ETHTOOL_LINK_CABLE_UNPLUGGED, /* Cable unplugged */
> +	ETHTOOL_LINK_UNSUPP_MODULE, /* Unsupported module */
> +	ETHTOOL_LINK_I2C_BUS_ERR, /* I2C bus error */

Which I2C bus? What about MDIO BUS errors?

> +	ETHTOOL_LINK_UNSUPP_EEPROM, /* Unsupported EEPROM */

Which EEPROM?

> +	ETHTOOL_LINK_OVERTEMP, /* Over temperature */
> +	ETHTOOL_LINK_PWR_BUDGET_EXC, /* Power budget exceeded */
> +	ETHTOOL_LINK_MODULE_ADMIN_DOWN, /* Module admin down */

It seems like these last 6 are all SFP issues? How about putting SFP
into the name?

     Andrew
