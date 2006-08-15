From: Dan Williams <dcbw@redhat.com>
Subject: Re: proposal for new wireless configuration API
Date: Tue, 15 Aug 2006 14:14:48 -0400
Message-ID: <1155665688.8940.10.camel@localhost.localdomain>
References: <1155655728.17742.30.camel@ux156>
	 <1155659387.3005.15.camel@localhost.localdomain>
	 <200608151838.58182.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jean Tourrilhes <jt@hpl.hp.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:31451 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1030434AbWHOSPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 14:15:53 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200608151838.58182.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-15 at 18:38 +0200, Michael Buesch wrote:
> On Tuesday 15 August 2006 18:29, Dan Williams wrote:
> > o Separate attributes for channel and frequency
> 
> No, channel and freq is the same. It's just another name
> for the same child. I would say we only want to deal with channel numbers
> in the API. That's much easier, as we don't have to deal with this
> fixed-point (or even floating point) mess. Look at WE for the
> fixed-point mess.

Right, I don't have a problem with only using one or the other; but we
_HAVE_ to provide a function in the driver that allows userspace
programs to convert channel <-> frequency both ways, like you suggest
below.  Obviously the channel/frequency mapping isn't the same
everywhere.

[ or is it?  I'd be very uncomfortable using the same channel #s
everywhere unless some IEEE spec states exactly what the channel #s are
for every frequency range that wireless stuff operates in ]

> The userspace tools can easily convert freq to channel and back.
> And in the kernel, we can easily provide some small function
> to convert from channel to khz and back, for example. But I would
> like to see the fixed-point stuff in the API vanish.

No argument here; as long as we provide the mapping function in the
driver for each card.

> > o Method of finding out channel <-> frequency mapping (not all drivers
> > support this in the SIOCGIWRANGE handler now)
> 
> Yes, that would be a good idea.
> Comes next to the conversion function (see above).

Yep.

Dan

