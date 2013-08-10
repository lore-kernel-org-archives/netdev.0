From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/4] drivers/net: enic: Make ASIC information available
 to USNIC
Date: Sat, 10 Aug 2013 18:13:25 +0200
Message-ID: <1376151205.32005.2.camel@deadeye.wl.decadent.org.uk>
References: <1376071941-17001-1-git-send-email-neepatel@cisco.com>
	 <1376071941-17001-4-git-send-email-neepatel@cisco.com>
	 <20130809152135.11c19869@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neel Patel <neepatel@cisco.com>, <netdev@vger.kernel.org>,
	Nishank Trivedi <nistrive@cisco.com>,
	Christian Benvenuti <benve@cisco.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6253 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934403Ab3HJQNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 12:13:33 -0400
In-Reply-To: <20130809152135.11c19869@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-09 at 15:21 -0700, Stephen Hemminger wrote:
> On Fri,  9 Aug 2013 11:12:20 -0700
> Neel Patel <neepatel@cisco.com> wrote:
> 
> > This patch provides asic information via ethtool.
[...]
> > --- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
> > +++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
> > @@ -19,6 +19,7 @@
> >  #include <linux/netdevice.h>
> >  #include <linux/ethtool.h>
> >  
> > +#include "driver_utils.h"
> >  #include "enic_res.h"
> >  #include "enic.h"
> >  #include "enic_dev.h"
> > @@ -116,6 +117,9 @@ static void enic_get_drvinfo(struct net_device *netdev,
> >  		sizeof(drvinfo->fw_version));
> >  	strlcpy(drvinfo->bus_info, pci_name(enic->pdev),
> >  		sizeof(drvinfo->bus_info));
> > +	memset(drvinfo->reserved1, 0, sizeof(drvinfo->reserved1));
> > +	driver_encode_asic_info(drvinfo->reserved1, sizeof(drvinfo->reserved1),
> > +		fw_info->asic_type, fw_info->asic_rev);
> >  }
> 
> If you want to use a reserved field, then make it a first class citizen.
> Rename it to asic_info, make sure the result is okay for other drivers
> and add send patch so Ben can make it part of normal ethtool support.
> 
> Otherwise, this code is likely to break when someone else actually unreserves
> that field.

Right.  I bet this is redundant with the IDs that lspci can show,
anyway.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
