From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.4] backport neighbour cache redesign
Date: Mon, 4 Oct 2004 13:20:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004132034.00cfe23c.davem@davemloft.net>
References: <20040930154753.GD1860@sunbeam.de.gnumonks.org>
	<20041004121759.26798f1d.davem@davemloft.net>
	<20041004201525.GF27499@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20041004201525.GF27499@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 4 Oct 2004 22:15:25 +0200
Harald Welte <laforge@gnumonks.org> wrote:

> If we go back to the initial reason for all those modifications, it was
> deployment in large networks.  The gc_thresh3 default of 1k is very
> small, even if you have only 4 interfaces with /24, you will already max
> out this default.
> 
> Now that the hash distribution is better, and the table resized
> dynamically, we scale better with large neighbour caches.
> 
> I was thinking of registering with some notifiers and tuning gc_thresh3
> automatically to be at least as large as the theoretical number of
> immediate neigbhours.  At least for multiple /24 and /16 I think this is
> still reasonable.
> 
> As soon as we go further up (/8 or ipv6) the limit basically becomes
> 'unlimited', since we won't be able to receive 2^24 arp-causing packets
> per second anyway.
> 
> Or be even less conservative and say: there is no limit for neighbour
> cache entries?  You mentioned that *BSD didn't have a limit, IIRC.

I think tieing it to the subnet size is wrong, because the real
cap is the routing cache size.  Remember the email where I was
talking about that?

I'm nearly ambivalent about a bound-less neighbour cache.  I hate
to think about having tons of crap sitting in the neighbour cache
unused and sucking up memory.  BSD's scheme works because when routing
entries die so do the neighbour entries they point to, so they have no
need for garbage collection like we do.

So right now I think a better idea is to have the routing cache tell
the neigh table how big it could get, or something like that.
It is a thorny issue, since usually routing cache --> neighbour cache
assosciations are VERY many to one except in these weird odd cases.
