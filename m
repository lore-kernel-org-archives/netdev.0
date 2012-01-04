From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] net/davinci: do not use all descriptors for tx packets
Date: Wed, 4 Jan 2012 09:50:01 +0100
Message-ID: <20120104085001.GM5446@pengutronix.de>
References: <1325604467-15122-1-git-send-email-s.hauer@pengutronix.de>
 <20120103.135141.1199352202815384466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, anantgole@ti.com, srk@ti.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55816 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275Ab2ADIuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 03:50:03 -0500
Content-Disposition: inline
In-Reply-To: <20120103.135141.1199352202815384466.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 03, 2012 at 01:51:41PM -0500, David Miller wrote:
> From: Sascha Hauer <s.hauer@pengutronix.de>
> Date: Tue,  3 Jan 2012 16:27:47 +0100
> 
> > The driver uses a shared pool for both rx and tx descriptors.
> > During open it queues fixed number of 128 descriptors for receive
> > packets. For each received packet it tries to queue another
> > descriptor. If this fails the descriptor is lost for rx.
> > The driver has no limitation on tx descriptors to use, so it
> > can happen during a nmap / ping -f attack that the driver
> > allocates all descriptors for tx and looses all rx descriptors.
> > The driver stops working then.
> > To fix this limit the number of tx descriptors used to half of
> > the descriptors available, the rx path uses the other half.
> > 
> > Tested on a custom board using nmap / ping -f to the board from
> > two different hosts.
> > 
> > Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
> 
> Applied to net-next, thanks.
> 
> Well, at this point there is not logical reason to have a shared
> descriptor pool unless the hardware requires it.  Does it?

I don't have enough knowledge of the hardware to give an answer, but to
me it would appear like a very strange piece of hardware if it can
only receive *or* transmit depending on the type of the next descriptor.
I think the driver needs some cleanup in this area, but this is out of
skope for me at the moment.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
