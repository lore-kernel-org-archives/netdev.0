From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] option for large routing hash
Date: Wed, 10 Dec 2003 15:05:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210150537.5fd0edb0.davem@redhat.com>
References: <16343.12816.917811.588853@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16343.12816.917811.588853@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Dec 2003 15:47:44 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> The RCU/sofirq stuff pop-up again (now with routing table loaded).
> RCU will probable get on the agenda again as from what I heard the
> netfilter folks have plans to use it.

I wish we had resolved that in the long thread we had about it
a few months ago.  We should really reestablish the point we had
reached, and try to make some more forward progress.

This problem is not going to go away, as you say.

> But when hit <= tot we have at least two cases:
> 1) Traffic is not well behaved. DoS.
> 2) Traffic is well behaved but tuning is bad.

#2 should be prevented by the fact that GC prefers to toss out entries
in an LRU'ish manner.

I think I see what you're saying though, and in my opinion there
is way too much black magic in choosing gc_thresh etc. routing cache
parameters.

Other caches in the kernel grow to fill the needs of the system.  The
routing cache grows only as large as it has been configured to be
allowed to grow, and afterwards it no longer responds to increasing
system needs.

The IPV4 routing front end has exactly this kind of logic.  As you
load more and more routing table entries into the kernel it grows
the hashes in response.

> So it crucial to distinguish between the cases. Can it be done from
> incoming traffic? 

This is the real question, and the other is how to implement dynamic
hash table growth in the routing cache.  The locking is particularly
problematic, but RCU may be able to help us with this.

Monitoring traffic to make this decision is hard because to determine
whether cache misses are due to not well formed traffic vs. too small
cache sizing we'd need the entry we garbage collected to determine the
latter.  It's the chicken and egg problem.
