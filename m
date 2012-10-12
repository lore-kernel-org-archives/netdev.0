From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Fri, 12 Oct 2012 09:43:56 +0800
Message-ID: <CACVXFVPdOkvKBBrshnmQv5cYVdDhi8j0V_WxNwBU9VuDsCLkXA@mail.gmail.com>
References: <1588459.VLxBbnNMlP@linux-lqwf.site>
	<Pine.LNX.4.44L0.1210111030570.1170-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oneukum@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:57298 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754400Ab2JLBn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 21:43:58 -0400
In-Reply-To: <Pine.LNX.4.44L0.1210111030570.1170-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 11, 2012 at 10:36 PM, Alan Stern <stern@rowland.harvard.edu> wrote:

>
> It's worse than you may realize.  When a SCSI disk is suspended, all of
> its ancestor devices may be suspended too.  Pages can't be read in from
> the drive until all those ancestors are resumed.  This means that all
> runtime resume code paths for all drivers that could be bound to an
> ancestor of a block device must avoid GFP_KERNEL.  In practice it's

Exactly, so several subsystems(for example, pci, usb, scsi) will be involved,
and converting GFP_KERNEL in runtime PM path to GFP_NOIO becomes
more difficult.

> probably easiest for the runtime PM core to use tsk_set_allowd_gfp()
> before calling any runtime_resume method.

Yes, it might be done in usb runtime resume context because all
usb device might include a mass storage interface. But, in fact,
we can find if there is one mass storage interface on the current
configuration easily inside usb_runtime_resume().

Also, we can loose the constraint in runtime PM core, before calling
runtime_resume callback for one device, the current context is marked
as ~GFP_IOFS only if it is a block device or there is one block device
descendant. But the approach becomes a bit complicated because
device tree traversing is involved.


Thanks,
--
Ming Lei
