From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Behaviour of ETHTOOL_GLINK for an interface that's down
Date: Thu, 09 Dec 2010 18:05:39 +0000
Message-ID: <1291917939.2647.10.camel@bwh-desktop>
References: <1291672786.5405.23.camel@bwh-desktop>
	 <1291873629.24551.7.camel@dcbw.foobar.com>
	 <1291874559.24551.10.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:6703 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752888Ab0LISFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 13:05:42 -0500
In-Reply-To: <1291874559.24551.10.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-12-09 at 00:02 -0600, Dan Williams wrote:
> On Wed, 2010-12-08 at 23:47 -0600, Dan Williams wrote:
> > On Mon, 2010-12-06 at 21:59 +0000, Ben Hutchings wrote:
> > > ETHTOOL_GLINK is yet another ethtool operation that has unclear
> > > semantics that results in differing behaviour when the interface is
> > > down.
[...]
> > > DaveM said that Network Manager may require (2), although I don't think
> > > this is correct.  At least the current version brings all managed
> > > interfaces up whether or not they have link-up already.
> > 
> > NM has used netlink + IFF_RUNNING (not ethtool) for a few years for
> > actual carrier detection.  Ethtool (and MII ioctls) are called as a
> > "best effort" method of determining that the device actually *has*
> > carrier detection at all, since if the device has gone to the trouble to
> > implement either MII or ethtool, it probably also has carrier detection.
> > 
> > But ethtool isn't actually used to determine carrier status in NM.  It's
> > netlink all the way down.
> 
> And as a follow-on, yes, NM does bring all devices it is allowed to
> manager IFF_UP because that's the only way (at this point) that we can
> guarantee functional carrier detect from the card.  I'd love it if that
> weren't the case, and if we could have some indicator that the driver
> could do carrier detect while in a lower-power state and !IFF_UP, but we
> don't have that yet.

Thanks for the information, Dan.  Presumably it would actually be
sufficient for NM's requirements to implement 'energy detect' which some
PHYs can do even in a low power state?  (Though I wonder whether that
works between two PHYs both in a low power state.)  You could then use
this as a trigger to bring the interface up, while still relying on the
existing link change notification to trigger interface configuration.
But this clearly has to be separate from ETHTOOL_GLINK, not least
because you want notification rather than having to poll.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

