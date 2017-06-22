From: Gal Pressman <galp@mellanox.com>
Subject: Re: [RFC PATCH net-next 1/3] ethtool: Add link down reason callback
Date: Thu, 22 Jun 2017 11:09:04 +0300
Message-ID: <8e7ffead-350e-bd7f-c7ea-fe057969d0d3@mellanox.com>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
 <1498050286-17141-2-git-send-email-galp@mellanox.com>
 <20170621135809.GC27585@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr00046.outbound.protection.outlook.com ([40.107.0.46]:46240
        "EHLO EUR02-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751674AbdFVIJO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 04:09:14 -0400
In-Reply-To: <20170621135809.GC27585@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> +enum {
>> +	ETHTOOL_LINK_VENDOR_SPECIFIC = -1, /* Vendor specific issue provided in vendor_reason */
>> +	ETHTOOL_LINK_NO_ISSUE, /* No issue observed with link */
>> +	ETHTOOL_LINK_REASON_UNKNOWN, /* Unknown reason */
> I think OTHER would be better that UNKNOWN. 

Fine with me.
>> +	ETHTOOL_LINK_NETDEV_CARRIER_DOWN, /* Netdev carrier is down */
>> +	ETHTOOL_LINK_ADMIN_DOWN, /* Admin down */
> These two are interesting. We have that information already. Why do we
> want it again?

My goal is to gather all link issue reasons in one place.
I don't want the user to gather pieces of other reports just to get a sense of what's wrong.
>> +	ETHTOOL_LINK_AN_FAILED, /* Auto negotiation failed */
>> +	ETHTOOL_LINK_TRAINING_FAILED, /* Link training failed */
>> +	ETHTOOL_LINK_RMT_FAULT, /* Remote fault indication */
>> +	ETHTOOL_LINK_BAD_SIGNAL_INTEGRITY, /* Bad signal integrity */
>> +	ETHTOOL_LINK_CABLE_MISMATCH, /* Cable protocol mismatch */
>> +	ETHTOOL_LINK_INTERNAL_ERR, /* Internal error */
> How does an internet error differ from an UNKNOWN?

Internal error means I know what happened but I can't tell you, your vendor support might be
able to provide a better analysis.
Unknown means that the driver doesn't have any useful information that can help in this case.
>> +	ETHTOOL_LINK_CABLE_UNPLUGGED, /* Cable unplugged */
>> +	ETHTOOL_LINK_UNSUPP_MODULE, /* Unsupported module */
>> +	ETHTOOL_LINK_I2C_BUS_ERR, /* I2C bus error */
> Which I2C bus? What about MDIO BUS errors?

The I2C bus that's connected to this module (interface).
We can add another reason for MDIO BUS errors or merge to one BUS error reason.
>> +	ETHTOOL_LINK_UNSUPP_EEPROM, /* Unsupported EEPROM */
> Which EEPROM?

Module EEPROM.
>> +	ETHTOOL_LINK_OVERTEMP, /* Over temperature */
>> +	ETHTOOL_LINK_PWR_BUDGET_EXC, /* Power budget exceeded */
>> +	ETHTOOL_LINK_MODULE_ADMIN_DOWN, /* Module admin down */
> It seems like these last 6 are all SFP issues? How about putting SFP
> into the name?

Might be a QSFP issue for example, we can put module in the name though.
>
>      Andrew
