From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH] usbnet: Activate halt interrupt endpoint before re-submit URB
Date: Wed, 20 Jun 2012 18:56:23 +0800
Message-ID: <CACVXFVOJzctAs-giOmC-0J5LfLsp1YSwrcRK4UEyPAejFc05rg@mail.gmail.com>
References: <CA+v9cxad+THL8u7tr_ubD7H7o+6x+qTOXOgowmPDnWUxa8aJtQ@mail.gmail.com>
	<201206201058.55519.oneukum@suse.de>
	<CACVXFVMy6Hrqgw6rmAXv5YXD86sLF+FUPTRRcXKs40uwN6ioCg@mail.gmail.com>
	<201206201221.37211.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Huajun Li <huajun.li.lee@gmail.com>,
	David Miller <davem@davemloft.net>, stern@rowland.harvard.edu,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:47232 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756582Ab2FTK4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 06:56:24 -0400
In-Reply-To: <201206201221.37211.oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 20, 2012 at 6:21 PM, Oliver Neukum <oneukum@suse.de> wrote:

> It probably was halted and cleared. However that you cleared
> a halt doesn't mean that the reason for stalling went away.
> So you must cope with an endpoint being halted again right after
> it was cleared.

I only suggested we should handle -EPIPE for usb_submit_urb
on interrupt endpoint, maybe it is the 1st handling, at least it is
per USB spec.

Also from implementation of usb gadget device, generally
ClearFeature(HALT) is to clear the some halt related flag of
endpoint hardware.

Looks the reasons of interrupt endpoint stalling is invisible
for usbnet driver, so it is not easy to handle the situation
you described(halted and cleared repeatedly).

>
>> > In that case we'd need to do something more intrusive
>> > like resetting the device, but that cannot be done well
>> > in the generic usbnet part.
>>
>> IMO, resetting is not needed for -EPIPE, but may be needed for
>> -EPROTO failure.
>
> We don't need it for a single failure, but what else would we do
> if we keep getting -EPIPE?

Suppose the case will happen, what is the appropriate actions
usbnet should take on the failure? I am not sure RESET can deal
with it.

Also is it a actual failure case or only a theory case?

Thanks,
-- 
Ming Lei
