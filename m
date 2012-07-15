From: Jon Mason <jon.mason@intel.com>
Subject: Re: [RFC 1/2] PCI-Express Non-Transparent Bridge Support
Date: Sun, 15 Jul 2012 16:50:41 -0700
Message-ID: <20120715235041.GB7551@jonmason-lab>
References: <1342215900-3358-1-git-send-email-jon.mason@intel.com>
 <20120714170411.GA25775@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:23038 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750748Ab2GOXul (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jul 2012 19:50:41 -0400
Content-Disposition: inline
In-Reply-To: <20120714170411.GA25775@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 14, 2012 at 10:04:11AM -0700, Greg KH wrote:
> On Fri, Jul 13, 2012 at 02:44:59PM -0700, Jon Mason wrote:
> > The NTB device driver is needed to configure these memory windows, doorbell, and
> > scratch-pad registers as well as use them in such a way as they can be turned
> > into a viable communication channel to the remote system.  ntb_hw.[ch]
> > determines the usage model (NTB to NTB or NTB to Root Port) and abstracts away
> > the underlying hardware to provide access and a common interface to the doorbell
> > registers, scratch pads, and memory windows.  These hardware interfaces are
> > exported so that other, non-mainlined kernel drivers can access these.
> 
> Why would you have non-mainlined drivers?
> 
> Can you submit the drivers at the same time so we see how you are using
> these new interfaces?

There are none at this time.  In the near future, the transport will be modified to use IOAT instead of the CPU copy to improve throughput performance, and it may be beneficial to have that separate.  If you wish for me to remove the hooks until it is necessary for that, then I can.

> 
> > +++ b/drivers/ntb/ntb_hw.c
> > @@ -0,0 +1,1283 @@
> > +/*
> > + * This file is provided under a dual BSD/GPLv2 license.  When using or
> > + *   redistributing this file, you may do so under either license.
> > + *
> > + *   GPL LICENSE SUMMARY
> > + *
> > + *   Copyright(c) 2012 Intel Corporation. All rights reserved.
> > + *
> > + *   This program is free software; you can redistribute it and/or modify
> > + *   it under the terms of version 2 of the GNU General Public License as
> > + *   published by the Free Software Foundation.
> > + *
> > + *   This program is distributed in the hope that it will be useful, but
> > + *   WITHOUT ANY WARRANTY; without even the implied warranty of
> > + *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> > + *   General Public License for more details.
> > + *
> > + *   You should have received a copy of the GNU General Public License
> > + *   along with this program; if not, write to the Free Software
> > + *   Foundation, Inc., 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
> > + *   The full GNU General Public License is included in this distribution
> > + *   in the file called LICENSE.GPL.
> 
> You really want to track the office movements of the FSF for the next 40
> years?  You should ask your lawyers if you can remove this paragraph.

Standard boilerplate junk, but it never hurts to ask.
 
> > +/**
> > + * ntb_hw_link_status() - return the hardware link status
> > + * @ndev: pointer to ntb_device instance
> > + *
> > + * Returns true if the hardware is connected to the remote system
> > + *
> > + * RETURNS: true or false based on the hardware link state
> > + */
> > +bool ntb_hw_link_status(struct ntb_device *ndev)
> > +{
> > +	return ndev->link_status == NTB_LINK_UP;
> > +}
> > +EXPORT_SYMBOL(ntb_hw_link_status);
> 
> EXPORT_SYMBOL_GPL() perhaps, for these, and the other symbols you are
> creating?

Will do.

> 
> thanks,
> 
> greg k-h
