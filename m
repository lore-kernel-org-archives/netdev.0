From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Mon, 27 Sep 2004 11:57:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927115740.4d4b4c2a.davem@davemloft.net>
References: <20040923225158.23c2d502.davem@davemloft.net>
	<20040924085234.GE3236@sunbeam.de.gnumonks.org>
	<20040924142702.62a2b23d.davem@davemloft.net>
	<20040925064406.GL3236@sunbeam.de.gnumonks.org>
	<20040925005623.2faf8faf.davem@davemloft.net>
	<20040925090933.GU3236@sunbeam.de.gnumonks.org>
	<20040927092933.GG3236@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040927092933.GG3236@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 11:29:33 +0200
Harald Welte <laforge@gnumonks.org> wrote:

> > > 4) The controversial/RFC patch, dorking with neigh_forced_gc()
> 
> It performed perfectly, I wasn't able to reproduce those overflows
> anymore (testing with two /16 networks and about 200kpps incoming
> packets to unresolved and non-existant neighbours)
> 
> > I'll do tests with and without INCOMPLETE check. No results until late
> > Sunday/Monday, as indicated above.
> 
> I didn't even bother doing the INCOMPLETE check since Yoshifuji
> indicated that this caused problems with IPv6....

You might as well have.  Effectively, due to a bug that Herbert Xu
spotted, diff4 acts the same as if the INCOMPLETE checks were
removed.  The time_after() check for INCOMPLETE entries in the
diff4 changes ended up being opposite of what it should be.

Yoshifuji said:

> So, I cannot agree simiply removing the "INCOMPLETE" test.

What some standard says is meaningless in these sorts
of situations.  It lacks any sense.  If we are reaching
limits of caches and we need to create a new neighbour entry
in order to communicate with another hosts we must purge
anything we can.  I challenge something like TAHI to even
be able to check out a case like this and for the results to
be meaningful in some way.  They certainly won't be.

So I'm going to remove the INCOMPLETE tests instead of my
original diff4 since:

1) That is effectively what my buggy diff4 was doing anyways.
2) It is the simplest change and keeps us from having to scan
   the hash table twice under high load situations when we need
   the cycles very badly.

Yoshifuji, if we drop neighbour entry, we will just reprobe for
this neighbour if we should try to communicate with it again.
It is not the end of the world.
