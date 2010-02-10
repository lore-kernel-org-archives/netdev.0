From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] usbnet: convert dev(dbg|err|warn|info) macros to
 usbnet_(dbg|err|warn|info)
Date: Tue, 09 Feb 2010 22:16:18 -0800
Message-ID: <1265782578.20626.17.camel@Joe-Laptop.home>
References: <3d8577211d88cce1fb6f4c1b54c5aa413a1f325a.1265765892.git.joe@perches.com>
	 <201002092153.22322.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Neukum <oliver@neukum.name>,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1942 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751141Ab0BJGQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 01:16:20 -0500
In-Reply-To: <201002092153.22322.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-02-09 at 21:53 -0800, David Brownell wrote: 
> On Tuesday 09 February 2010, Joe Perches wrote:
> > These macros are too similar to the dev_<level> equivalents
> > but take a usbnet * argument.
> 
> FYI the history behind that, as I recall, was that the names
> were part of the effort to get rid of kernel 2.4 USB-specific
> macros like err() and info(), or maybe uppercased versions of
> them ... where the dev_err() style messaging wasn't so helpful,
> since it didn't say which network device was involved.

Maybe these usbnet_printk macros could use the proposed
netdev_printk macros instead.

http://patchwork.ozlabs.org/patch/44955/

Maybe:

#define usbnet_dbg(usbnet, fmt, arg...)		\
	netdev_dbg((usbnet)->net, fmt, ##arg)
#define usbnet_err(usbnet, fmt, arg...)		\
	netdev_err((usbnet)->net, fmt, ##arg)
#define usbnet_warn(usbnet, fmt, arg...)	\
	netdev_err((usbnet)->net, fmt, ##arg)
#define usbnet_info(usbnet, fmt, arg...)	\
	netdev_info((usbnet)->net, fmt, ##arg)

or just use netdev_printks directly.

> Good point that this should be improved.

I neglected to mention that to make the use
style more like the rest of kernel source, this
patch also changes the macro definitions by
removing the \n added to the format and adds the
trailing "\n" to the callers.

Except for the first one. (oops)

> Acked-by: David Brownell <dbrownell@users.sourceforge.net>
> ... should merge via netdev.


