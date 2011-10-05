From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] bridge: allow forwarding some link local frames
Date: Wed, 5 Oct 2011 13:50:59 -0700
Message-ID: <20111005135059.4fbb2912@nehalam.linuxnetplumber.net>
References: <20111004041444.793960297@vyatta.com>
	<20111004041509.292932641@vyatta.com>
	<1317843619.2802.32.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44942 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932307Ab1JEUvC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 16:51:02 -0400
In-Reply-To: <1317843619.2802.32.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Oct 2011 20:40:19 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Mon, 2011-10-03 at 21:14 -0700, Stephen Hemminger wrote:
> > plain text document attachment (bridge-multicast-filter.patch)
> > This is based on an earlier patch by Nick Carter with comments
> > by David Lamparter but with some refinements. Thanks for their patience
> > this is a confusing area with overlap of standards, user requirements,
> > and compatibility with earlier releases.
> > 
> > It adds a new sysfs attribute 
> >    /sys/class/net/brX/bridge/group_fwd_mask
> > that controls forwarding of frames with address of: 01-80-C2-00-00-0X
> > The default setting has no forwarding to retain compatibility.
> > 
> > One change from earlier releases is that forwarding of group
> > addresses is not dependent on STP being enabled or disabled. This
> > choice was made based on interpretation of tie 802.1 standards.
> > I expect complaints will arise because of this, but better to follow
> > the standard than continue acting incorrectly by default.
> > 
> > The filtering mask is writeable, but only values that don't forward
> > known control frames are allowed. It intentionally blocks attempts
> > to filter control protocols. For example: writing a 8 allows
> > forwarding 802.1X PAE addresses which is the most common request.
> [...]
> 
> I wonder why you don't forbid forwarding frames sent to reserved
> destination addresses?  The standards seem pretty clear that this should
> not be allowed.

Future proofing. Since addresses are unassigned there is no certainty of the
assigned semantics when they are used.
