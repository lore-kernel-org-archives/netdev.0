From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC/PATCH] sungem: Spring cleaning and GRO support
Date: Tue, 31 May 2011 23:17:29 +0100
Message-ID: <1306880249.2866.53.camel@bwh-desktop>
References: <1306828745.7481.660.camel@pasglop>
	 <1306875564.2866.39.camel@bwh-desktop>  <1306879088.7481.679.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"R. Herbst" <ruediger.herbst@googlemail.com>,
	Brian Hamilton <bhamilton04@gmail.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:3918 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932696Ab1EaWRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 18:17:32 -0400
In-Reply-To: <1306879088.7481.679.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-06-01 at 07:58 +1000, Benjamin Herrenschmidt wrote:
[...]
> > Is the pm_mutex really needed?  All control operations should already be
> > serialised by the RTNL lock, and you've started taking that in the
> > suspend and resume functions.
> 
> Well, it's been there forever and I need to get my head around it, but
> yes, the rtnl lock might be able to get rid of it, good point. I just
> actually added that :-)
> 
> So all ndo_set_* are going to be covered by rtnl including the ethtool ?

ethtool ops are almost all covered; the kernel-doc comment has the
details.

As for net_device_ops, locking varies (and really ought to be documented
in <linux/netdevice.h>).  At least ndo_set_mac_address, ndo_change_mtu
and ndo_do_ioctl (plus of course ndo_open and ndo_stop) are called
holding the RTNL lock.

> I don't really want to take the rtnl lock in the reset task (at least
> not for the whole duration of it), so I may have to be a bit creative on
> synchronization there.
[...]

Unless reset takes more than a second I wouldn't worry about it.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

