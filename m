From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 1/1] alx: add a simple AR816x/AR817x device driver
Date: Fri, 21 Jun 2013 00:09:17 +0200
Message-ID: <1371766157.8333.25.camel@jlt4.sipsolutions.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1370899746-14219-1-git-send-email-johannes@sipsolutions.net>
	 <1371518286.3495.60.camel@deadeye.wl.decadent.org.uk>
	 <1371764438.8333.20.camel@jlt4.sipsolutions.net>
	 <1371765508.8771.17.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com, Johannes Stezenbach <js@sig21.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:49156 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758411Ab3FTWJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 18:09:22 -0400
In-Reply-To: <1371765508.8771.17.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-20 at 22:58 +0100, Ben Hutchings wrote:

> > Yeah, no idea, just copy/paste. Lots of drivers seem to do this, for no
> > particular reason it seems?
> 
> As I said, most of them select MII which depended on NET_CORE, so they
> really did need to select NET_CORE too.  I've now fixed that.

Ok, I can kick out the 'select NET_CORE' here anyway as MDIO doesn't
need it. Or did you want to do a more general cleanup on this, then I'll
leave it to you?

> > Heh, ok. I actually played with this a bit and didn't like it much
> > either way ... There doesn't seem to be any combined enum, and if you
> > use separate fields then one is valid only if the other has a certain
> > value, etc... Anyway, I'll change it.
> 
> It seems to be a widely used trick, but it means that you may accept
> silly settings like speed = 99 duplex = 1.

Yes, though here it was really used only internally... Anyway, I killed
it, makes some code nicer and some a bit more awkward (more parameters)

> > > You should break out the code that
> > > sets ecmd->supported from alx_get_settings() and then do something like:
> > > 
> > > 	if (ecmd->advertising & ~alx_get_supported_mask())
> > > 		return -EINVAL;
> > > 
> > > here.
> > 
> > That... seems strange? It would rely on ADVERTISED_* and SUPPORTED_*
> > having the same value, which is probably true, but it still seems
> > confusing?
> 
> It is true and should remain true.  I don't know why they were ever
> defined separately in the first place.

Hmm, ok. I'll do it that way.

> > > I couldn't find where auto-negotiated flow control is programmed after
> > > the link comes up.  Maybe it isn't?
> > 
> > No idea, sorry. I clearly have a lot to learn about how ethernet devices
> > typically work, should it be programmed?
> 
> When autoneg is enabled, the PHY should perform autonegotiation whenever
> it detects an electrical link; if successful it will configure itself
> for the negotiated link speed and duplex, and trigger a link interrupt.
> But unless there is firmware running on the controller, the driver
> usually has to read PHY registers to get the result and then configure
> the MAC speed, duplex and flow control accordingly.

Ok, makes sense. I guess a bunch of these things are done in
alx_post_phy_link() or so, but yeah I don't see flow control either.

How would I even test that? Find random devices that have flow control?
I don't think I have anything that would be programmable, unless I don't
know about it being so :-)

johannes
