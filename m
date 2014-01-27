From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Many USB ethernet devices are broken over xhci
Date: Mon, 27 Jan 2014 15:33:26 -0800
Message-ID: <20140127233326.GB652@kroah.com>
References: <063D6719AE5E284EB5DD2968C1650D6D46624F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:37184 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753849AbaA0XcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 18:32:21 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D46624F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 27, 2014 at 04:06:22PM +0000, David Laight wrote:
> Many of the net/usb ethernet drivers (including common ones like
> the smsc95xx) will fail to transmit all packet length properly
> when connected to a USB3 port (ie using the xhci driver).

That's odd, as I've never had a problem with my USB 3.0 ethernet device
(sorry, don't remember what driver it uses), and I stress it all the
time.

I've also run two different USB 2 ethernet devices on xhci with no
issues at all, so perhaps the "many" statement might not be true?

> The underlying problem is that they assume the host controller
> will honour the URB_ZERO_PACKET flag - which usbnet sets because
> they specify FLAG_SEND_ZLP.
> 
> However no one has ever added support for URB_ZERO_PACKET to
> the xhci driver - so packets that need padding (probably 512
> bytes after any header is added) will not be sent correctly
> and may have very adverse effects on the usb target.

Really?  How has things been working so well up to now without this
support?  Doesn't the hardware automatically add this padding with no
explicit need for the xhci driver to do something?

> The ax179_178a driver avoids this by not setting FLAG_SEND_ZLP,
> modifying the packet header, and appending an extra zero byte.
> (Which has been responsible for its own set of panics.)
> 
> I don't think this can be fixed by just clearing (or ignoring)
> FLAG_SEND_ZLP as the extra byte will also confuse things.
> 
> It needs to be fixed in the xhci code.
> 
> I wrote this patch a while ago - worked for me with the ax179_178a
> driver. http://www.spinics.net/lists/linux-usb/msg97370.html

Doing multiple things in a patch is generally considered bad-form, and
this is quite hard to follow.

> The patch is a bit difficult to read, the v1 version contained a copy of
> the new function. http://www.spinics.net/lists/linux-usb/msg97183.html

That's not helpful to the people having to review the v2 patch :)

> I don't think anything significant has changed (in the main kernel
> sources) since I wrote the patch.

Then resubmit it, don't post links to it on the web, there's nothing we
can do with them, sorry.

thanks,

greg k-h
