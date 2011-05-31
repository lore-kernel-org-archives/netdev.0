From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [RFC/PATCH] sungem: Spring cleaning and GRO support
Date: Wed, 01 Jun 2011 09:55:32 +1000
Message-ID: <1306886132.29297.3.camel@pasglop>
References: <1306828745.7481.660.camel@pasglop>
	 <1306875564.2866.39.camel@bwh-desktop>  <1306879088.7481.679.camel@pasglop>
	 <1306880249.2866.53.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"R. Herbst" <ruediger.herbst@googlemail.com>,
	Brian Hamilton <bhamilton04@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:56136 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932956Ab1EaXzm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2011 19:55:42 -0400
In-Reply-To: <1306880249.2866.53.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-31 at 23:17 +0100, Ben Hutchings wrote:
> On Wed, 2011-06-01 at 07:58 +1000, Benjamin Herrenschmidt wrote:
> [...]
> > > Is the pm_mutex really needed?  All control operations should already be
> > > serialised by the RTNL lock, and you've started taking that in the
> > > suspend and resume functions.
> > 
> > Well, it's been there forever and I need to get my head around it, but
> > yes, the rtnl lock might be able to get rid of it, good point. I just
> > actually added that :-)
> > 
> > So all ndo_set_* are going to be covered by rtnl including the ethtool ?
> 
> ethtool ops are almost all covered; the kernel-doc comment has the
> details.
> 
> As for net_device_ops, locking varies (and really ought to be documented
> in <linux/netdevice.h>).  At least ndo_set_mac_address, ndo_change_mtu
> and ndo_do_ioctl (plus of course ndo_open and ndo_stop) are called
> holding the RTNL lock.

Ok. The main annoyance for locking has always been set_multicast which
is called with a spinlock afaik.

> > I don't really want to take the rtnl lock in the reset task (at least
> > not for the whole duration of it), so I may have to be a bit creative on
> > synchronization there.
> [...]
> 
> Unless reset takes more than a second I wouldn't worry about it.

I don't want to take a spinlock for even near that, especially since we
do the reset on every link down. I suppose rtnl might be less of an
issue, I'll have a look.

Cheers,
Ben.


