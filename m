From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 1/3] ethtool: Add link down reason callback
Date: Sun, 25 Jun 2017 17:19:53 +0200
Message-ID: <20170625151953.GA7799@lunn.ch>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
 <1498050286-17141-2-git-send-email-galp@mellanox.com>
 <20170621135809.GC27585@lunn.ch>
 <8e7ffead-350e-bd7f-c7ea-fe057969d0d3@mellanox.com>
 <20170624190435.GN4875@lunn.ch>
 <f216ad74-772b-0f6c-1303-ecb0c12afc96@mellanox.com>
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
Received: from vps0.lunn.ch ([178.209.37.122]:34322 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751020AbdFYPT7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Jun 2017 11:19:59 -0400
Content-Disposition: inline
In-Reply-To: <f216ad74-772b-0f6c-1303-ecb0c12afc96@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 25, 2017 at 02:59:24PM +0300, Gal Pressman wrote:
> 
> > On Thu, Jun 22, 2017 at 11:09:04AM +0300, Gal Pressman wrote:
> >>>> +enum {
> >>>> +	ETHTOOL_LINK_VENDOR_SPECIFIC = -1, /* Vendor specific issue provided in vendor_reason */
> >>>> +	ETHTOOL_LINK_NO_ISSUE, /* No issue observed with link */
> >>>> +	ETHTOOL_LINK_REASON_UNKNOWN, /* Unknown reason */
> >>> I think OTHER would be better that UNKNOWN. 
> >> Fine with me.
> >>>> +	ETHTOOL_LINK_NETDEV_CARRIER_DOWN, /* Netdev carrier is down */
> >>>> +	ETHTOOL_LINK_ADMIN_DOWN, /* Admin down */
> >>> These two are interesting. We have that information already. Why do we
> >>> want it again?
> >> My goal is to gather all link issue reasons in one place.
> > I'm actually wondering if this is a user space problem. Nearly
> > everything you list is already available. Some you get from ip link,
> > others from ethtool or ethtool --module-info, including I2C bus
> > error, since you would expect EIO or ETIMEOUT.
> >
> > If you were to write a user space tool using the information what is
> > currently available, what would be missing?
> >
> > 	  Andrew
> 
> I think most of the reasons in this list would be missing.
> Auto negotiation failure,

You can probably get that from the PHY layer. You get both the local
and remote AN capabilities.

> unplugged, over temperature, power budget exceeded..

Don't you get over temperature from the SFF data? Also power budget?

And what does cable unplugged actually mean? Do you have a micro
switch inside the socket? So that is maybe a gpio-key?

Another thing to remember is that your device is the exception to the
rule. You have some firmware doing a lot of the work bringing this all
together. But nearly every other Ethernet interface has a discrete MAC
and PHY, I2C bus driver, EEPROM driver, generic SFF decoder, HWMON
temperature sensor, etc. How does your call work in this normal
situation? How do you make calls into all these subsystems to get the
information? You want a generic solution which can be made to work for
everybody.

	Andrew




> 
> Keep in mind that this is just an initial list, not to mention the vendor reasons which are not part of any existing API.
> I don't see how a user space tool that expects ETIMEOUT/EIO is better than this suggestion.
