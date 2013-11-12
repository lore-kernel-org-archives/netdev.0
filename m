From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP performance regression
Date: Tue, 12 Nov 2013 08:42:43 +0100
Message-ID: <20131112074243.GA10318@1wt.eu>
References: <1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com> <21120.29720.673157.151074@gargle.gargle.HOWL> <1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com> <21120.37647.979237.40802@gargle.gargle.HOWL> <1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B73F9@saturn3.aculab.com> <1384183799.16391.39.camel@edumazet-glaptop2.roam.corp.google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B73FB@saturn3.aculab.com> <1384186622.16391.44.camel@edumazet-glaptop2.roam.corp.google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B73FD@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Sujith Manoharan <sujith@msujith.org>, netdev@vger.kernel.org,
	Dave Taht <dave.taht@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:49680 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423Ab3KLHmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Nov 2013 02:42:52 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73FD@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 04:35:30PM -0000, David Laight wrote:
> > > It should be ok if the mac driver only gives the hardware a small
> > > number of bytes/packets - or one appropriate for the link speed.
> > 
> > There is some confusion here.
> > 
> > mvneta has a TX ring buffer, which can hold up to 532 TX descriptors.
> > 
> > If this driver used skb_orphan(), a single TCP flow could use the whole
> > TX ring.
> > 
> > TCP Small Queue would only limit the number of skbs on Qdisc.
> > 
> > Try then to send a ping message, it will have to wait a lot.
> 
> 532 is a ridiculously large number especially for a slow interface.
> At a guess you don't want more than 10-20ms of data in the tx ring.

Well, it's not *that* large, 532 descriptors is 800 kB or 6.4 ms with
1500-bytes packets, and 273 microseconds for 64-byte packets. In fact
it's not a slow interface, it's the systems it runs on which are
generally not that fast. For example it is possible to saturate two
gig ports at once on a single-core Armada370. But you need buffers
large enough to compensate for the context switch time if you use
multiple threads to send.

Regards,
Willy
