From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: net/usb/ax88179_178a driver broken in linux-3.12
Date: Wed, 20 Nov 2013 08:54:20 -0800
Message-ID: <20131120165420.GD9611@xanatos>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B742F@saturn3.aculab.com>
 <528A9A36.50903@pobox.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7431@saturn3.aculab.com>
 <20131119.161313.743887333007019981.davem@davemloft.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7439@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mlord@pobox.com,
	eric.dumazet@gmail.com, ming.lei@canonical.com,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40774 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753953Ab3KTQyV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Nov 2013 11:54:21 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7439@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 20, 2013 at 09:54:02AM -0000, David Laight wrote:
> > From: Of David Miller
> > > From: "David Laight" <David.Laight@ACULAB.COM>
> > > Date: Tue, 19 Nov 2013 10:04:11 -0000
> > 
> > > There is a patch to xhci-ring.c that should fix the SG problem.
> > > http://www.spinics.net/lists/linux-usb/msg97176.html
> > >
> > > I think it should apply to the 3.12 sources.
> > 
> > David, please get this into Linus's tree and queued up for -stable
> > as soon as possible, thank you.
> 
> What do I have to do to expedite it?
> I thought that Sarah would have to push the patch through.

Yes, I think the patch should come through my tree.

> It might be necessary to limit the number of SG fragments that
> the mass storage (etc) can generate to 63 (from unlimited).
> That should be a 1 line change somewhere.

Greg's USB tree is frozen until after 3.13-rc1.  The patch will have to
wait until then, but it will be marked for stable.

I have no objection to the methodology of the patch, but we do need to
figure out how to limit the number of scatter-gather list entries in the
mass storage driver.  We're still figuring out the exact limitation we
need to use, and then the patch can be queued in my for-usb-linus branch
for 3.13-rc1.

Note that the patch is a bandaid fix, and will only help bulk endpoints
that are submitting scatter-gather transfers.  Interrupt endpoints using
scatter-gather will still run into these issues, but with David's patch,
the URB submission will now fail, rather than allowing the transfer to
be silently corrupted.

The real fix for this will probably be too large for stable, and is
likely to take at least a kernel revision to fix.

Sarah Sharp
