From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [linux-usb-devel] [PATCH RFC] ZyDAS ZD1211 USB-WLAN driver
Date: Sat, 10 Jun 2006 13:23:06 +0200
Message-ID: <20060610112306.GA19198@p15091797.pureserver.info>
References: <44817083.508@gentoo.org> <200606031951.09135.oliver@neukum.org> <4481E497.2000505@gentoo.org> <200606040025.32275.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>,
	linux-usb-devel@lists.sourceforge.net,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:39124 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1751488AbWFJLXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jun 2006 07:23:07 -0400
To: Oliver Neukum <oliver@neukum.org>
Content-Disposition: inline
In-Reply-To: <200606040025.32275.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-06-04 00:25 Oliver Neukum wrote:

> > > +static void disconnect(struct usb_interface *intf)
> > > This is racy. It allows io to disconnected devices. You must take the
> > > lock and set a flag that you test after you've taken the lock elsewhere.
> > 
> > Will fix, thanks.
> 
> You're welcome

Not so fast, because I don't know what to fix.

Actually there are two cases, when disconnect is called. The first
is, when the device is removed. The second is, when the kernel
module is removed from the kernel. It should also be recognized
that disconnect() must always succeed, so we have to ignore IO
errors anyhow.

In the first case we don't need the IO and in the second case we
have to do it, because otherwise, the device will not come up, if
we load the driver again.

Testing shows, that doing the IO doesn't create a lot of issues,
there are some errors reported, but that's it and the second case
just works fine. So there doesn't appear a problem and even if
want to be "clean", I would like to know, how to distinguish both
cases without trying to do IO with the device.

In  the meanwhile I removed the misleading comment about locking.
I would like also like to know, that beside the fact that device
IO fails, which races can happen?

-- 
Uli Kunitz
