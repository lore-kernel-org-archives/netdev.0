From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Wed, 10 Oct 2012 19:02:02 +0800
Message-ID: <CACVXFVPDg89y7LyKLA0YUN7oA2rGfptfHLZhJrqBjTVPjsGdNg@mail.gmail.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
	<1631246.gHVDWoZpLi@linux-lqwf.site>
	<CACVXFVMq8-t2o5=M=3xCQEiPFXjvH14g3NtRgOTMYr542d5zXw@mail.gmail.com>
	<1691674.ASueyuVmUn@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:48099 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292Ab2JJLCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 07:02:05 -0400
In-Reply-To: <1691674.ASueyuVmUn@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 10, 2012 at 6:08 PM, Oliver Neukum <oneukum@suse.de> wrote:

>
> A reset always applies to the whole device. Resets are used in error
> handling of block devices (storage and uas). If you reset a device,
> pre_reset() and post_reset() of all interfaces need to be called. So they
> are part of the SCSI error handler. SCSI error handlers can allocate memory
> only with GFP_NOIO (or GFP_ATOMIC) because any IO for paging
> can cause the SCSI layer to wait for the error handling to finish. The error
> handling can only finish when pre/post_reset() have finished. Catch-22

IMO, it is not practical to obey the rule for drivers, because driver may
call many other kernel component API which may allocate memory
via GFP_KERNEL in the path easily.

Same with runtime PM case.

>
> So any control messages in block error handling need to use GFP_NOIO.
> If you look at the control message helpers in usbcore you will find a lot
> of GFP_NOIO. That is the reason.

If one driver has no .pre_reset or .post_reset, usb_reset_device() will
try to unbind&bind the interface, so you mean these usb drivers have
to use GFP_NOIO to allocate memory in its probe() and disconnect()?
Unfortunately, that is not true, and no way to make sure all memory
allocations in the path via GFP_NOIO, IMO.

Also, only very few drivers have implemented .pre_reset and .post_reset.

Thanks,
--
Ming Lei
