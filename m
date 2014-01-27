From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: Many USB ethernet devices are broken over xhci
Date: Mon, 27 Jan 2014 15:16:43 -0800
Message-ID: <20140127231643.GE2860@xanatos>
References: <063D6719AE5E284EB5DD2968C1650D6D46624F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61020 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754141AbaA0XQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 18:16:47 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D46624F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, you are overwhelming my capacity to handle patches right now.  I
appreciate that you would like to clean up the driver, but the bug fixes
you're sending me are getting lost in the noise of random cleanup
patches.

Can you please limit the xHCI patches you send to bug fixes for now?
Also, can you resend all the patches you consider to be serious bug
fixes in one single patchset?

Thanks,
Sarah Sharp

On Mon, Jan 27, 2014 at 04:06:22PM +0000, David Laight wrote:
> Many of the net/usb ethernet drivers (including common ones like
> the smsc95xx) will fail to transmit all packet length properly
> when connected to a USB3 port (ie using the xhci driver).
> 
> The underlying problem is that they assume the host controller
> will honour the URB_ZERO_PACKET flag - which usbnet sets because
> they specify FLAG_SEND_ZLP.
> 
> However no one has ever added support for URB_ZERO_PACKET to
> the xhci driver - so packets that need padding (probably 512
> bytes after any header is added) will not be sent correctly
> and may have very adverse effects on the usb target.
> 
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
> 
> The patch is a bit difficult to read, the v1 version contained a copy of
> the new function. http://www.spinics.net/lists/linux-usb/msg97183.html
> 
> I don't think anything significant has changed (in the main kernel
> sources) since I wrote the patch.
> 
> 	David
> 
> 
> 
> 
