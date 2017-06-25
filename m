From: Gal Pressman <galp@mellanox.com>
Subject: Re: [RFC PATCH net-next 1/3] ethtool: Add link down reason callback
Date: Sun, 25 Jun 2017 14:59:24 +0300
Message-ID: <f216ad74-772b-0f6c-1303-ecb0c12afc96@mellanox.com>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
 <1498050286-17141-2-git-send-email-galp@mellanox.com>
 <20170621135809.GC27585@lunn.ch>
 <8e7ffead-350e-bd7f-c7ea-fe057969d0d3@mellanox.com>
 <20170624190435.GN4875@lunn.ch>
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
Received: from mail-ve1eur01on0045.outbound.protection.outlook.com ([104.47.1.45]:42713
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750975AbdFYL7e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Jun 2017 07:59:34 -0400
In-Reply-To: <20170624190435.GN4875@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Thu, Jun 22, 2017 at 11:09:04AM +0300, Gal Pressman wrote:
>>>> +enum {
>>>> +	ETHTOOL_LINK_VENDOR_SPECIFIC = -1, /* Vendor specific issue provided in vendor_reason */
>>>> +	ETHTOOL_LINK_NO_ISSUE, /* No issue observed with link */
>>>> +	ETHTOOL_LINK_REASON_UNKNOWN, /* Unknown reason */
>>> I think OTHER would be better that UNKNOWN. 
>> Fine with me.
>>>> +	ETHTOOL_LINK_NETDEV_CARRIER_DOWN, /* Netdev carrier is down */
>>>> +	ETHTOOL_LINK_ADMIN_DOWN, /* Admin down */
>>> These two are interesting. We have that information already. Why do we
>>> want it again?
>> My goal is to gather all link issue reasons in one place.
> I'm actually wondering if this is a user space problem. Nearly
> everything you list is already available. Some you get from ip link,
> others from ethtool or ethtool --module-info, including I2C bus
> error, since you would expect EIO or ETIMEOUT.
>
> If you were to write a user space tool using the information what is
> currently available, what would be missing?
>
> 	  Andrew

I think most of the reasons in this list would be missing.
Auto negotiation failure, link training failure, remote fault indication, bad signal integrity, cable protocol mismatch, cable unplugged,
over temperature, power budget exceeded..

Keep in mind that this is just an initial list, not to mention the vendor reasons which are not part of any existing API.
I don't see how a user space tool that expects ETIMEOUT/EIO is better than this suggestion.
