From: Pavel Roskin <proski@gnu.org>
Subject: Re: Can we have GET_NETDEV_DEV?
Date: Tue, 25 Jul 2006 17:08:11 -0400
Message-ID: <1153861691.2288.14.camel@dv>
References: <1153803145.23803.19.camel@dv>
	 <20060725102005.7edb5509@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:37277 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S932497AbWGYVIQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 17:08:16 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1G5U8V-0007BD-KS
	for netdev@vger.kernel.org; Tue, 25 Jul 2006 17:08:15 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060725102005.7edb5509@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Stephen!

On Tue, 2006-07-25 at 10:20 -0700, Stephen Hemminger wrote:

> So how about these wrappers.

> +static inline void netdev_set_pdev(struct net_device *dev, struct device *pdev)
> +{
> +	dev->class_dev.dev = pdev;
> +}
> +
> +static inline struct device *netdev_get_pdev(struct net_device *dev)
> +{
> +	return dev->class_dev.dev;
> +}

The positive effect of a macro is that if would allow MadWifi to prepare
in advance by testing if GET_NETDEV_DEV is defined.

The functions may or may not be useful for the code in the kernel, but
I'll not be able to prepare MadWifi unless I know the kernel version in
which they will appear.

Considering the drivers that are already in the kernel, you may prefer
to have a more high-level function that would clone the network device
by copying most of the net_device structure.  I think netdev_get_pdev()
would be mostly used for such cloning if implemented.

-- 
Regards,
Pavel Roskin


