From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [PATCH] tbf scheduler: TSO support
Date: Fri, 11 May 2007 13:01:42 +0900 (JST)
Message-ID: <20070511.130142.16832866.taka@valinux.co.jp>
References: <46431687.7060600@trash.net>
	<20070510.141344.127196214.davem@davemloft.net>
	<4643C115.3020802@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <4643C115.3020802@trash.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> >>I don't see why this is needed, the correct way to use TBF with TSO
> >>is to specify a larger MTU value, in which case it won't drop TSO
> >>packets.
> > 
> > 
> > Why should a user have to know anything in the world about TSO in
> > order to configure TBF properly?  I don't think they should have
> > to at all.
> 
> 
> The user shouldn't necessarily, but userspace should.
> The way I see it the MTU is a fundamental parameter for TBF
> (the peakrate bucket size) and just because userspace picks
> a bad default (2000) this is no reason to change the
> implementation to something that is not really TBF anymore
> and even affects non-TSO packets _and_ TSO packets even
> when the MTU is chosen large enough (granted, the first
> point is an implementation detail). The much better solution
> would be to let userspace pick an appropriate default value
> and still let the user override it.

I think the concept of TBF is quit good but the userspace tools have
become old that it doesn't fit to Gb ethernet environment.
The tools should be updated to care about much faster network and
GbE jumbo frames. I agree with you at this point.

On the other hand, handling TSO packet should be a kernel issue.
A TSO packet is logically just a multiple segmented packet
including several ordinary packets. This feature should be kept
invisible from userspace.

And I also feel it's hard to determine how large TSO packets
can/will be accepted that it depends on ether controllers.
It would be also tough to make the tools catch up with the
latest off loading features.

Thank you,
Hirokazu Takahashi.



