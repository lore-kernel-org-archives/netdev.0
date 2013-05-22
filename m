From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: possible bug in IPv6 MLD retransmissions
Date: Wed, 22 May 2013 02:40:27 +0200
Message-ID: <20130522004027.GD32093@order.stressinduktion.org>
References: <20130517032449.GA3595@obelix.rh> <20130518173105.GD29528@order.stressinduktion.org> <20130521150616.GA8513@obelix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53859 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754105Ab3EVAk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 20:40:28 -0400
Content-Disposition: inline
In-Reply-To: <20130521150616.GA8513@obelix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 21, 2013 at 12:06:16PM -0300, Flavio Leitner wrote:
> On Sat, May 18, 2013 at 07:31:05PM +0200, Hannes Frederic Sowa wrote:
> > On Fri, May 17, 2013 at 12:24:49AM -0300, Flavio Leitner wrote:
> > > A tcpdump captured while adding an IPv6 link-local address shows
> > > two MLD reports. One with source ``::'' and another with the permanent
> > > address.
> > > 
> > > Well, if you increase dad_retransmits from 1 to 10, for instance,
> > > then both MLD reports are sent with source address ``::'' which
> > > according with specs should be ignored by the routers.
> > >
> > > [...]
> > >
> > > Therefore, I believe this is a bug in IPv6 MLD because it should
> > > sent at least 2 MLD reports after DAD is completed.
> > > The specs says:
> > >
> > > [..]
> > >
> > > Does that make any sense?
> > 
> > Yes, this is unfortunate. RFC3590 clarifies this also for MLDv1 messages.
> > 
> > Could you try following patch I just came up with?
> 
> It does work, but it would be better to send [Robustness Variable]
> times, right?

Sure, this is the more robust approach.

Patch is tested and seems fine:

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

I tried to track if we actually used the unspecified address to send out
mld reports, but doing this correctly (multiple link-local addresses in
dad state) needed a bit of ugly lock handling and the code got bloated. So
I do think it is not worth the effort.

Thanks,

  Hannes
