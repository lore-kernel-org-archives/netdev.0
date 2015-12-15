From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as drain mode
Date: Tue, 15 Dec 2015 20:44:10 +0100
Message-ID: <20151215194410.GB3187@1wt.eu>
References: <1447222769.17135.92.camel@edumazet-glaptop2.roam.corp.google.com> <CALx6S37FOq+JVs8LKh5ezR9JhATrz2=NhmbEYPUxUt8Cyb9xaw@mail.gmail.com> <1447262610.17135.114.camel@edumazet-glaptop2.roam.corp.google.com> <CALx6S37B4mGqYe63JkLmPeQNuOX_WMK2NHaOe7Dtt79Nv9Mo4g@mail.gmail.com> <1447267424.17135.115.camel@edumazet-glaptop2.roam.corp.google.com> <1447290541.22599.11.camel@edumazet-glaptop2.roam.corp.google.com> <20151215161456.GA3182@1wt.eu> <1450199424.8474.30.camel@edumazet-glaptop2.roam.corp.google.com> <20151215174346.GA3187@1wt.eu> <1450203712.8474.46.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:45911 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754121AbbLOToW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2015 14:44:22 -0500
Content-Disposition: inline
In-Reply-To: <1450203712.8474.46.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 15, 2015 at 10:21:52AM -0800, Eric Dumazet wrote:
> On Tue, 2015-12-15 at 18:43 +0100, Willy Tarreau wrote:
> 
> > Ah ? but what does it bring in this case ? I'm not seeing it used
> > anywhere on a listening socket. The code took care of not breaking
> > them though (ie they still accept if no other socket shows up with
> > a higher score). Otherwise we'll have to switch to Tolga's patch,
> > unless we find another socket option that can safely be combined
> > and which makes sense (I often find it better not to make userland
> > depend on new updates of includes when possible).
> 
> Socket options set on the listener before the accept() are inherited.

I completely forgot about this use case, stupid me!

> Applications wanting SO_LINGER special settings on all their sockets can
> use a single system call right before listen().
> 
> Some servers having to deal with TIME_WAIT proliferation very often use
> SO_LINGER with timeout 0

Yes definitely, it's just that I was focused on the listening socket not
taking into account the fact that it would be inherited to the (rare) few
sockets that are accepted from the queue afterwards. And indeed it's a
perfectly legitimate usage to save a syscall per incoming connection.

Thus do you think it's worth adding a new option as Tolga proposed ?

Another solution I considered (but found a bit dirty) was to make use of
the unimplemented shutdown(WR) for this. While it's easy to do, I don't
like it simply because it looks like a hack and not logical at all from
the users perspective.

Thanks,
Willy
