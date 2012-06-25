From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/3 net-next] tg3: Add sysfs file to export sensor data
Date: Mon, 25 Jun 2012 22:25:54 +0100
Message-ID: <1340659554.2572.52.camel@bwh-desktop.uk.solarflarecom.com>
References: <1340237192-30052-1-git-send-email-mchan@broadcom.com>
	 <1340237192-30052-2-git-send-email-mchan@broadcom.com>
	 <1340237192-30052-3-git-send-email-mchan@broadcom.com>
	 <20120622.172651.932738000786251092.davem@davemloft.net>
	 <1340413453.4344.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <1340463729.6345.25.camel@deadeye.wl.decadent.org.uk>
	 <1340658258.4344.43.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<nsujir@broadcom.com>, <mcarlson@broadcom.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:59336 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756237Ab2FYVZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 17:25:58 -0400
In-Reply-To: <1340658258.4344.43.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-25 at 14:04 -0700, Michael Chan wrote:
> On Sat, 2012-06-23 at 16:02 +0100, Ben Hutchings wrote: 
> > Temperature and voltage can be exposed through an hwmon device (which
> > practically means you use multiple attributes with conventional names).
> > Other diagnostics might possible be suitable for ethtool stats,
> > depending on what they are.
> 
> I think we can extract some common and more useful attributes such as
> temperature and voltage, and use the standard hwmon attributes to expose
> them.
> 
> > 
> > If the driver can't easily parse the information (e.g. it varies greatly
> > between the different chips and firmware versions) then a binary
> > attribute or private ioctl might be appropriate.  But generic interfaces
> > really should be considered first.
> > 
> 
> The rest of the bulk data requires too much parsing in the kernel and
> will have to be exposed as binary data.  What do you mean by binary
> attribute?  A new binary sysfs attribute under hwmon?  Or outside of
> hwmon?

A binary sysfs attribute under your PCI device.  (In fact, for wider
userland compatibility, hwmon sysfs attributes should also be under the
PCI device rather than the hwmon device.  Yes, this *is* a weird
convention.)

> And please elaborate on the private ioctl.

Every driver gets to handle SIOCDEVPRIVATE .. SIOCDEVPRIVATE+15.  But
avoid the first 3, as userland may blindly try to use them for MDIO.
David may of course tell you that you should under no circumstances
actually do this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
