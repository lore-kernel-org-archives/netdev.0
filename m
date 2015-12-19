From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as drain mode
Date: Sat, 19 Dec 2015 08:00:09 +0100
Message-ID: <20151219070009.GA4634@1wt.eu>
References: <1450199424.8474.30.camel@edumazet-glaptop2.roam.corp.google.com> <20151215174346.GA3187@1wt.eu> <1450203712.8474.46.camel@edumazet-glaptop2.roam.corp.google.com> <20151215194410.GB3187@1wt.eu> <1450214475.8474.50.camel@edumazet-glaptop2.roam.corp.google.com> <20151216073814.GA3373@1wt.eu> <20151216161514.GA3476@1wt.eu> <CAO5YkUSL=k3UxmuqkGN666YSvH-=UGKCZvRgqqBnnr1EPRqRtw@mail.gmail.com> <20151218185812.GD4448@1wt.eu> <1450492683.8474.123.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgallek@google.com, Josh Snyder <josh@code406.com>,
	Tom Herbert <tom@herbertland.com>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:64323 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752619AbbLSHAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Dec 2015 02:00:22 -0500
Content-Disposition: inline
In-Reply-To: <1450492683.8474.123.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2015 at 06:38:03PM -0800, Eric Dumazet wrote:
> On Fri, 2015-12-18 at 19:58 +0100, Willy Tarreau wrote:
> > Hi Josh,
> > 
> > On Fri, Dec 18, 2015 at 08:33:45AM -0800, Josh Snyder wrote:
> > > I was also puzzled that binding succeeded. Looking into the code paths
> > > involved, in inet_csk_get_port, we quickly goto have_snum. From there, we end
> > > up dropping into tb_found. Since !hlist_empty(&tb->owners), we end up checking
> > > that (tb->fastreuseport > 0 && sk->sk_reuseport && uid_eq(tb->fastuid, uid)).
> > > This test passes, so we goto success and bind.
> > > 
> > > Crucially, we are checking the fastreuseport field on the inet_bind_bucket, and
> > > not the sk_reuseport variable on the other sockets in the bucket. Since this
> > > bit is set based on sk_reuseport at the time the first socket binds (see
> > > tb_not_found), I can see no reason why sockets need to keep SO_REUSEPORT set
> > > beyond initial binding.
> > > 
> > > Given this, I believe Willy's patch elegantly solves the problem at hand.
> > 
> > Great, thanks for your in-depth explanation.
> > 
> > Eric, do you think that this patch may be acceptable material for next
> > merge window (given that it's not a fix per-se) ? If so I'll resubmit
> > later.
> 
> I need to check with Craig Gallek, because he was about to upstream a
> change to make SO_REUSEPORT more scalable & sexy (like having an [e]BPF
> filter to perform the selection in an array of sockets)

OK fine. Please note that I also considered using a new value instead of
zero there but I preferred to avoid it since the man talked about zero/
non-zero so I wanted to limit any API change. If Craig adds new values
there then this is something we can reconsider.

Have a nice week-end,
Willy
