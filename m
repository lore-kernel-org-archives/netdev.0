From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] usbnet: Activate halt interrupt endpoint before re-submit URB
Date: Wed, 20 Jun 2012 10:58:55 +0200
Message-ID: <201206201058.55519.oneukum@suse.de>
References: <CA+v9cxad+THL8u7tr_ubD7H7o+6x+qTOXOgowmPDnWUxa8aJtQ@mail.gmail.com> <201206201000.21845.oneukum@suse.de> <CACVXFVPDV5v3gW5wz44kBsXm0KreHJnkvoxEPZhnLVoaTDw-Yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Huajun Li <huajun.li.lee@gmail.com>,
	David Miller <davem@davemloft.net>, stern@rowland.harvard.edu,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56024 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752167Ab2FTI64 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:58:56 -0400
In-Reply-To: <CACVXFVPDV5v3gW5wz44kBsXm0KreHJnkvoxEPZhnLVoaTDw-Yw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 20. Juni 2012, 10:07:55 schrieb Ming Lei:
> On Wed, Jun 20, 2012 at 4:00 PM, Oliver Neukum <oneukum@suse.de> wrote:
> >
> > Very well, on second thought, this patch makes sense.
> > Could you resend and I'll ack?
> 
> BTW, maybe it is better to add below
> 
>     usbnet_defer_kevent(dev, EVENT_STS_HALT);
> 
> for -EPIPE returned from usb_urb_submit if it will be resent.

Why? If it failed once it'll probably also fail the next time.
In that case we'd need to do something more intrusive
like resetting the device, but that cannot be done well
in the generic usbnet part.

	Regards
		Oliver
