From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Mon, 18 Nov 2013 15:03:23 +0000
Message-ID: <1384787003.10077.34.camel@deadeye.wl.decadent.org.uk>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B740B@saturn3.aculab.com>
	 <Pine.LNX.4.44L0.1311131113090.1424-100000@iolanthe.rowland.org>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B741A@saturn3.aculab.com>
	 <1384565904.29151.66.camel@bwh-desktop.uk.level5networks.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7428@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:12325 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171Ab3KRPDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 10:03:31 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7428@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-18 at 09:48 +0000, David Laight wrote:
> > > But the minimum fragment size is (probably) 4k.
> > > For the network stack an OUT transfer might have a lot (and I mean lots)
> > > of fragments (there may be constraints, and linearising the skb is a option).
> > [...]
> > 
> > The maximum number of fragments in the skb is going to be 17 (including
> > the 'head' area).  (I'm ignoring NETIF_F_FRAGLIST which is not normally
> > supported by physical device drivers.)
> > 
> > I don't know how many fragments that can end up as, at the USB level.
> 
> If you assume that every fragment crosses a 64k boundary that would be 34.
> OTOH I've not seen a fragment of a 64k TSO send crossing a 32k
> boundary, and I think the 'head' area is constrained to be part of
> a single (4k or larger) page.

I don't know that it's possible at the moment, but I wouldn't recommend
relying on that.

> Isn't there something odd about skb merged by receive offload?
> I've not entirely sorted out the full structure of skb.

There has been some work to allow for using both the frags array and
frag list, but a driver will not see such an skb if it does not
advertise the NETIF_F_FRAGLIST feature.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
