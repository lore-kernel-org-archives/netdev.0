From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] usbnet: Activate halt interrupt endpoint before re-submit URB
Date: Wed, 20 Jun 2012 12:21:37 +0200
Message-ID: <201206201221.37211.oneukum@suse.de>
References: <CA+v9cxad+THL8u7tr_ubD7H7o+6x+qTOXOgowmPDnWUxa8aJtQ@mail.gmail.com> <201206201058.55519.oneukum@suse.de> <CACVXFVMy6Hrqgw6rmAXv5YXD86sLF+FUPTRRcXKs40uwN6ioCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Huajun Li <huajun.li.lee@gmail.com>,
	David Miller <davem@davemloft.net>, stern@rowland.harvard.edu,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34105 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753552Ab2FTKVi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 06:21:38 -0400
In-Reply-To: <CACVXFVMy6Hrqgw6rmAXv5YXD86sLF+FUPTRRcXKs40uwN6ioCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 20. Juni 2012, 12:15:25 schrieb Ming Lei:
> On Wed, Jun 20, 2012 at 4:58 PM, Oliver Neukum <oneukum@suse.de> wrote:
> > Am Mittwoch, 20. Juni 2012, 10:07:55 schrieb Ming Lei:
> >> BTW, maybe it is better to add below
> >>
> >>     usbnet_defer_kevent(dev, EVENT_STS_HALT);
> >>
> >> for -EPIPE returned from usb_urb_submit if it will be resent.
> >
> > Why? If it failed once it'll probably also fail the next time.
> 
> -EPIPE just means the endpoint is halted, either from usb_urb_submit
> or urb->status, so the HALT should be cleared in the situation.

It probably was halted and cleared. However that you cleared
a halt doesn't mean that the reason for stalling went away.
So you must cope with an endpoint being halted again right after
it was cleared.

> > In that case we'd need to do something more intrusive
> > like resetting the device, but that cannot be done well
> > in the generic usbnet part.
> 
> IMO, resetting is not needed for -EPIPE, but may be needed for
> -EPROTO failure.

We don't need it for a single failure, but what else would we do
if we keep getting -EPIPE?

	Regards
		Oliver
