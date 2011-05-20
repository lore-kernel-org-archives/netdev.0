From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Fri, 20 May 2011 13:37:47 +0100
Message-ID: <20110520133747.2b8fb2b0@lxorguk.ukuu.org.uk>
References: <1305715384-81716-1-git-send-email-tsunanet@gmail.com>
	<20110518.152653.1486764697527722925.davem@davemloft.net>
	<BANLkTik-6wh8=jb6oMEpJvYC8+KTGGsMsw@mail.gmail.com>
	<20110518.155200.801089483916944725.davem@davemloft.net>
	<20110518202025.GC4175@nuttenaction>
	<BANLkTimtA9BB7g5cOm8c9sGChQjf1P0Q-Q@mail.gmail.com>
	<fc49a1b4c32eee9b5cbfbeec4729eef5@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>,
	David Miller <davem@davemloft.net>, <tsunanet@gmail.com>,
	<kuznet@ms2.inr.ac.ru>, <pekkas@netcore.fi>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fc49a1b4c32eee9b5cbfbeec4729eef5@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> For our environment it hurts because we _always_ have an initial RTO >1. I
> understand and accept that 98% will benefit of this modification, no doubt
> Jerry! Try to put yourself in our situation: imaging a proposal of an init
> RTO modification to 0.5 seconds. Maybe because 98% of Internet traffic is
> now localized and the RTO is average now 0.2 seconds. Anyway, this will
> penalize your network always and this will be the situation for one of my
> customer. I can live with that, I see the benefits for the rest of the
> world. But I am happy to see a knob where I can restore the old behavior.
> Maybe some other environments will benefit from a even lower or higher
> initial RTO.

AX.25 is definitely happier with a multi-second round trip but it's a
special case. Some X.25 networks are going to have similar behaviour.

It shouldn't be penalising each connection (and it's worse than that of
course because each node on a shared media network gets in the way of the
rest, plus the queueing effect of all the extra blockages) because done
right multiple connections to the same host can use the previous
connections as estimates (and indeed for the initial RTO there's a good
argument for treating estimates as 'host, then x.y.z.* match, then
average of previous except the x.y.z.* match, then unknown')

The latter would fix an awful lot of the weird cases pretty effectively.

Alan
