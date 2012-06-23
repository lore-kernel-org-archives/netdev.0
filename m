From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/3 net-next] tg3: Add sysfs file to export sensor data
Date: Sat, 23 Jun 2012 16:02:09 +0100
Message-ID: <1340463729.6345.25.camel@deadeye.wl.decadent.org.uk>
References: <1340237192-30052-1-git-send-email-mchan@broadcom.com>
	 <1340237192-30052-2-git-send-email-mchan@broadcom.com>
	 <1340237192-30052-3-git-send-email-mchan@broadcom.com>
	 <20120622.172651.932738000786251092.davem@davemloft.net>
	 <1340413453.4344.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<nsujir@broadcom.com>, <mcarlson@broadcom.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:33702 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751613Ab2FWPCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2012 11:02:17 -0400
In-Reply-To: <1340413453.4344.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-22 at 18:04 -0700, Michael Chan wrote:
> On Fri, 2012-06-22 at 17:26 -0700, David Miller wrote: 
> > From: "Michael Chan" <mchan@broadcom.com>
> > Date: Wed, 20 Jun 2012 17:06:32 -0700
> > 
> > > Some tg3 devices have management firmware that can export data such as
> > > temperature and other real time diagnostics data.  Export this data to
> > > sysfs so that userspace can access this information.
> > > 
> > > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > > Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> > > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > 
> > I do not agree that sysfs is the appropriate place to export binary
> > data.
> > 
> 
> What's your suggestion?  ethtool?

Temperature and voltage can be exposed through an hwmon device (which
practically means you use multiple attributes with conventional names).
Other diagnostics might possible be suitable for ethtool stats,
depending on what they are.

If the driver can't easily parse the information (e.g. it varies greatly
between the different chips and firmware versions) then a binary
attribute or private ioctl might be appropriate.  But generic interfaces
really should be considered first.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
