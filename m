From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] driver core: Suppress sysfs warnings for
	device_rename().
Date: Tue, 20 May 2008 15:52:07 -0700
Message-ID: <20080520225207.GF15912@kroah.com>
References: <20080515095246.3b6a0d1d@gondolin.boeblingen.de.ibm.com> <20080515.010139.219194657.davem@davemloft.net> <20080515113131.2cea2bce@gondolin.boeblingen.de.ibm.com> <20080515.030054.247673168.davem@davemloft.net> <20080515120619.6c867bfb@gondolin.boeblingen.de.ibm.com> <20080520125913.777ed67d@gondolin.boeblingen.de.ibm.com> <20080520144508.410ed857@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>,
	David Miller <davem@davemloft.net>, fubar@us.ibm.com,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:50558 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933747AbYETWxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 18:53:44 -0400
Content-Disposition: inline
In-Reply-To: <20080520144508.410ed857@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 20, 2008 at 02:45:08PM -0700, Stephen Hemminger wrote:
> On Tue, 20 May 2008 12:59:13 +0200
> Cornelia Huck <cornelia.huck@de.ibm.com> wrote:
> 
> > OK, here is an actually-compiled patch with proper description and
> > s-o-b. Comments?
> > 
> > -----
> > 
> > driver core: Suppress sysfs warnings for device_rename().
> > 
> > Renaming network devices to an already existing name is not
> > something we want sysfs to print a scary warning for, since the
> > callers can deal with this correctly. So let's introduce
> > sysfs_create_link_nowarn() which gets rid of the common warning.
> > 
> > Signed-off-by: Cornelia Huck <cornelia.huck@de.ibm.com>
> >
> 
> This is still getting to be overkill. I prefer that the warnings
> always are removed.

No, I do not.  They have found a lot of real bugs that have been going
unnoticed for quite some time, and some new ones (like the current mess
in the pci hotplug subsystem where two different drivers are controlling
the same pci hotplug slots and not realizing it at all.)

So having the warning gone for rename() is fine, but I still want it
there for new files that are being added to the system.

thanks,

greg k-h
