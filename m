From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Sun, 26 Sep 2004 13:21:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040926112120.GV31616@rei.reeler.org>
References: <20040923225158.23c2d502.davem@davemloft.net> <20040924085234.GE3236@sunbeam.de.gnumonks.org> <20040924142702.62a2b23d.davem@davemloft.net> <20040925064406.GL3236@sunbeam.de.gnumonks.org> <20040925005623.2faf8faf.davem@davemloft.net> <20040925090933.GU3236@sunbeam.de.gnumonks.org> <20040925203116.4e6f9b06.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@gnumonks.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040925203116.4e6f9b06.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20040925203116.4e6f9b06.davem@davemloft.net> 2004-09-25 20:31
> 1) Parameterizing neigh_forced_gc() so that it purges say "N"
>    entries each run instead of scanning the entire hash table.
>    Perhaps some fraction of tbl->entries

I'm not familiar with the neighbour code but here's a wild
thought:

Calculate the average number of neigh additions (A) over the last
few minutes. Count the number of additions since the last call
to neigh_forced_gc() (L). Make N depdendant on L, the faster the
list grows the more entries we should check by each run to avoid
the list growing too fast. Calculate a aggresivity factor out
of A and L and remove stale and incomplete entries depending on this
factor. Maybe L needs to be calculate from the last few gc runs.

I don't know if any of this is implemented already or whether
it's possible or not. The basic idea is to figure out unnatural
situations and handle them more aggressively.
