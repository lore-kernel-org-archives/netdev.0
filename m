From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as drain mode
Date: Wed, 16 Dec 2015 08:38:14 +0100
Message-ID: <20151216073814.GA3373@1wt.eu>
References: <1447262610.17135.114.camel@edumazet-glaptop2.roam.corp.google.com> <CALx6S37B4mGqYe63JkLmPeQNuOX_WMK2NHaOe7Dtt79Nv9Mo4g@mail.gmail.com> <1447267424.17135.115.camel@edumazet-glaptop2.roam.corp.google.com> <1447290541.22599.11.camel@edumazet-glaptop2.roam.corp.google.com> <20151215161456.GA3182@1wt.eu> <1450199424.8474.30.camel@edumazet-glaptop2.roam.corp.google.com> <20151215174346.GA3187@1wt.eu> <1450203712.8474.46.camel@edumazet-glaptop2.roam.corp.google.com> <20151215194410.GB3187@1wt.eu> <1450214475.8474.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:49063 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932681AbbLPHiX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 02:38:23 -0500
Content-Disposition: inline
In-Reply-To: <1450214475.8474.50.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 15, 2015 at 01:21:15PM -0800, Eric Dumazet wrote:
> On Tue, 2015-12-15 at 20:44 +0100, Willy Tarreau wrote:
> 
> > Thus do you think it's worth adding a new option as Tolga proposed ?
> 
> 
> I thought we tried hard to avoid adding the option but determined
> we could not avoid it ;)

Not yet, your other proposal of disabling SO_REUSEPORT makes sense if
we combine it with the proposal to change the score in my patch. If
we say that a socket which has SO_REUSEPORT scores higher, then the
connections which don't want to accept new connections anymore will
simply have to drop it an not be elected. I find this even cleaner
since the sole purpose of the loop is to find the best socket in case
of SO_REUSEPORT.

I'll give this a try and will submit such a proposal if that works
for me.

Cheers!
Willy
