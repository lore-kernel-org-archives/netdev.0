From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/4] drivers/net: enic: Make ASIC information available
 to USNIC
Date: Tue, 13 Aug 2013 10:31:36 +0200
Message-ID: <1376382696.14079.90.camel@deadeye.wl.decadent.org.uk>
References: <1376071941-17001-1-git-send-email-neepatel@cisco.com>
	  <1376071941-17001-4-git-send-email-neepatel@cisco.com>
	  <20130809152135.11c19869@nehalam.linuxnetplumber.net>
	 <1376151205.32005.2.camel@deadeye.wl.decadent.org.uk>
	 <5209BFB2.2090003@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Neel Patel <neepatel@cisco.com>, <netdev@vger.kernel.org>,
	Christian Benvenuti <benve@cisco.com>,
	"Upinder Malhi (umalhi)" <umalhi@cisco.com>
To: Nishank Trivedi <nistrive@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34183 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122Ab3HMIbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 04:31:42 -0400
In-Reply-To: <5209BFB2.2090003@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-08-12 at 22:10 -0700, Nishank Trivedi wrote:
> On 8/10/13 9:13 AM, Ben Hutchings wrote:
> > On Fri, 2013-08-09 at 15:21 -0700, Stephen Hemminger wrote:
> >> On Fri,  9 Aug 2013 11:12:20 -0700
> >> Neel Patel <neepatel@cisco.com> wrote:
> >>
> >>> This patch provides asic information via ethtool.
> > [...]
> >>> --- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
> >>> +++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
> >>> @@ -19,6 +19,7 @@
> >>>   #include <linux/netdevice.h>
> >>>   #include <linux/ethtool.h>
> >>>
> >>> +#include "driver_utils.h"
> >>>   #include "enic_res.h"
> >>>   #include "enic.h"
> >>>   #include "enic_dev.h"
> >>> @@ -116,6 +117,9 @@ static void enic_get_drvinfo(struct net_device *netdev,
> >>>   		sizeof(drvinfo->fw_version));
> >>>   	strlcpy(drvinfo->bus_info, pci_name(enic->pdev),
> >>>   		sizeof(drvinfo->bus_info));
> >>> +	memset(drvinfo->reserved1, 0, sizeof(drvinfo->reserved1));
> >>> +	driver_encode_asic_info(drvinfo->reserved1, sizeof(drvinfo->reserved1),
> >>> +		fw_info->asic_type, fw_info->asic_rev);
> >>>   }
> >>
> >> If you want to use a reserved field, then make it a first class citizen.
> >> Rename it to asic_info, make sure the result is okay for other drivers
> >> and add send patch so Ben can make it part of normal ethtool support.
> >>
> >> Otherwise, this code is likely to break when someone else actually unreserves
> >> that field.
> >
> > Right.  I bet this is redundant with the IDs that lspci can show,
> > anyway.
> 
> Thanks Stephen, Ben for your input, they are valid points. Neel would 
> send a new patch series minus 3/4 for now.
> 
> While you are right that lspci or sysfs can be used to get same info, we 
> were trying to use asic info (encoded with type and version) within 
> drvinfo so as to use one string to achieve same effect as reading PCI 
> subsystem id and revision explicitly. Instead of going to different tool 
> (lspci), ethtool would be enough to unqiuely identify the device. Asic 
> version along with already existing firmware version, driver version, 
> etc seems natural.

Well we've managed without this for the last 15 years, so it seems like
it's not that much of a problem to run lspci too.

Sure, it's an extra command for users to run, but if you're trying to
get diagnostic information from them there's a *lot* more you'll want to
gather.

We could do something in the ethtool *command* to report what the device
is (if bus_info matches PCI address format), which would then work for
every PCI network driver.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
