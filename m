From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] ptp: increase the maximum number of clocks
Date: Mon, 25 Mar 2013 21:39:56 +0000
Message-ID: <1364247596.2710.18.camel@bwh-desktop.uk.solarflarecom.com>
References: <d219aa87bd5b3e2fa42449720d845a7110f642f0.1363893841.git.jbenc@redhat.com>
	 <20130321.172017.1499060411785395307.davem@davemloft.net>
	 <20130323175915.GA3036@netboy.at.omicron.at>
	 <20130325170855.0194ce13@griffin>
	 <20130325185120.GB3100@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@redhat.com>, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13817 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933102Ab3CYVj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 17:39:59 -0400
In-Reply-To: <20130325185120.GB3100@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-25 at 19:51 +0100, Richard Cochran wrote:
> On Mon, Mar 25, 2013 at 05:08:55PM +0100, Jiri Benc wrote:
> > On Sat, 23 Mar 2013 18:59:15 +0100, Richard Cochran wrote:
> > > Jiri, do you want to work on making the number of clocks essentially
> > > unlimited? If not, I can take a look at this, but not right away.
> > 
> > I'm currently thinking of using just /dev/ptp for all PHCs in the
> > system and specifying the desired network device (ifindex, likely)
> > by an ioctl as the very first operation. What do you think? If this
> > is viable, I can try to implement it.
> 
> While that might work for the PTP ioctls, it won't for the main
> clock_gettime/settime/adjtime call. As you wrote below, these take a
> dynamic clockid_t (which comes from a file descriptor), and so each
> device needs its own, unique file system node.
> 
> For better or worse, we are stuck with char devs, unless we want to
> redo the clock_xyz API. I certainly don't want to. We can have over a
> million PTP clocks on a single major number. That should be enough.
> 
> IIRC, it is possible to grow the range of minor numbers
> incrementally. Perhaps you could take a look at that?

MTD used to have a static table of devices, which was a problem for the
sfc driver as it exposes multiple partitions on each NIC through MTD.
It was reasonably easy to switch to dynamic numbering using the idr
library, and I expect that would also work for PTP clock devices.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
