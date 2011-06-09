From: Joe Perches <joe@perches.com>
Subject: Re: Request for review on Hyper-V virtual network driver
Date: Thu, 09 Jun 2011 15:28:17 -0700
Message-ID: <1307658497.18357.6.camel@Joe-Laptop>
References: <1307654865-30326-1-git-send-email-haiyangz@microsoft.com>
	 <1307655530.13329.49.camel@Joe-Laptop>
	 <A1F3067C9B68744AA19F6802BAB8FFDC09603E8F@TK5EX14MBXC227.redmond.corp.microsoft.com>
	 <20110609220701.GA24006@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Haiyang Zhang <haiyangz@microsoft.com>,
	Hank Janssen <hjanssen@microsoft.com>,
	KY Srinivasan <kys@microsoft.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2729 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755385Ab1FIW2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 18:28:18 -0400
In-Reply-To: <20110609220701.GA24006@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-09 at 15:07 -0700, Greg KH wrote:
> On Thu, Jun 09, 2011 at 09:59:19PM +0000, Haiyang Zhang wrote:
> > > -----Original Message-----
> > > From: Joe Perches [mailto:joe@perches.com]
> > > Sent: Thursday, June 09, 2011 5:39 PM
> > > >  create mode 100644 drivers/net/hyperv/netvsc.c
> > > >  create mode 100644 drivers/net/hyperv/netvsc_drv.c
> > > >  create mode 100644 drivers/net/hyperv/rndis_filter.c
> > > >  delete mode 100644 drivers/staging/hv/hyperv_net.h
> > > >  delete mode 100644 drivers/staging/hv/netvsc.c
> > > >  delete mode 100644 drivers/staging/hv/netvsc_drv.c
> > > >  delete mode 100644 drivers/staging/hv/rndis_filter.c
> > > 
> > > I suggest you resend this using the -M or --find-renames option.
> > 
> > Will do.
> 
> No, that will not show anything at all, which is the point of the
> review.  Otherwise it will just require someone to go look at the
> drivers/staging/hv/ directory in linux-next to properly determine what
> is happening here.
> 
> So this patch is fine for a review.

The line count of the files are different.

It's much more difficult to see what if anything has changed
between the two versions.

trivia:

All the message logging uses of dev_<level> should have
a terminating newline "\n" in netvsc.c

In netvsc.c dev_<level> messages are used.
In netvsc_drv.c netdev_<level> messages are used.

int netvsc_recv_callback(struct hv_device *device_obj,
                               struct hv_netvsc_packet *packet)
{
       struct net_device *net = dev_get_drvdata(&device_obj->device);

Maybe use the netdev_<level> style everywhere possible?

It's odd and a bit ugly to use #include "../../staging/hyperv.h"

Maybe add another include path to the Makefile and just use
#include "hyperv.h"
until all of the hyperv files are moved out of staging?



