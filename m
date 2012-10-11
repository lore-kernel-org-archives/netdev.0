From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Thu, 11 Oct 2012 16:14:02 +0800
Message-ID: <CACVXFVPjx+053r_-QB=8kPCDmk3va3feN9MYdLgpf=eRWGe05A@mail.gmail.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
	<4085386.s0fOKMaRDP@linux-lqwf.site>
	<CACVXFVMynoPm6_wYj2MD-5SvMpB7e1Wk94=XMp588rD8hU=eew@mail.gmail.com>
	<1588459.VLxBbnNMlP@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Alan Stern <stern@rowland.harvard.edu>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:52789 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932803Ab2JKIOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 04:14:05 -0400
In-Reply-To: <1588459.VLxBbnNMlP@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 11, 2012 at 12:11 PM, Oliver Neukum <oneukum@suse.de> wrote:
> On Thursday 11 October 2012 11:18:22 Ming Lei wrote:

>> Currently scsi disk can only be runtime suspended when the device is not
>> opened, so are you sure that the paging out above can cause IO on a suspend
>> usb mass storage disk which is not mounted or opened by utility now?
>
> We definitely do not wish to keep it that way. People at Intel are currently working
> on better power management for sd, which would allow full autosuspend.

OK, got it.

For auto-resume situation, it can be solved with switching the gpf_t flag
runtime inside helper, but I think it is better to do it after the sd's
full autosuspend is seen in -next tree.

For error handling case, it is inevitably for usbnet to allocate memory
with GFP_KERNEL because no usbnet drivers have implemented
.pre_reset and .post_reset callback, and no such actual problems
have been reported until now, so it should be OK to not consider the
case now.

So could we merge the patch set[1-11] first?

Thanks,
--
Ming Lei
