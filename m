From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Sat, 25 Sep 2004 14:33:42 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040925133342.GA11292@souterrain.chygwyn.com>
References: <20040923225158.23c2d502.davem@davemloft.net> <20040924085234.GE3236@sunbeam.de.gnumonks.org> <20040924142702.62a2b23d.davem@davemloft.net> <20040925064406.GL3236@sunbeam.de.gnumonks.org> <20040925005623.2faf8faf.davem@davemloft.net> <20040925090933.GU3236@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
Content-Disposition: inline
In-Reply-To: <20040925090933.GU3236@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

On Sat, Sep 25, 2004 at 11:09:33AM +0200, Harald Welte wrote:
> On Sat, Sep 25, 2004 at 12:56:23AM -0700, David S. Miller wrote:
> > So let's discuss #4.  It is the first idea I had to combat the
> > "problem", but honestly right now I am beginning to think that
> > the real solution is to simply remove the INCOMPLETE checks
> > altogether.
> > 
> > Neighbours are a sub-cache of the routing cache.  Therefore when
> > a neigh entry has a singular refcount, no routing cache entry
> > points to it.  No routing cache entry, we're not sending packets
> > to that neighbour any time soon, so there is no reason (especially
> > during strong pressure) to hold onto such entries.
> 
> I am sure this is valid for IPv4 and IPv6.  How about other users of the
> neighbour cache, do they share this assumption?  I have to admit that I
> never looked throgh the ATM or 
>
I cannot see this being any problem for DECnet at all.... the entry you
most want to hold on to is the entry for the default router of which
there will be a max of one per interface. This applies only in end node
mode and we hold a ref count to it anyway, so that it should have the
same effect as the routing cache entry holding a ref,

Steve.
