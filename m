From: "David S. Miller" <davem@redhat.com>
Subject: Re: linux 2.4 routing algorithm?
Date: Thu, 18 Sep 2003 19:57:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030918195753.676e76c8.davem@redhat.com>
References: <20030917234753.GB11250@sirius.cs.pdx.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kristen Carlson <kristenc@cs.pdx.edu>
In-Reply-To: <20030917234753.GB11250@sirius.cs.pdx.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 17 Sep 2003 16:47:53 -0700
Kristen Carlson <kristenc@cs.pdx.edu> wrote:

> I'm trying to understand the routing algorithm for linux 2.4.  I thought
> it would use a longest prefix match due to some documentation I had googled,
> but the code in route.c looks like a hash.  I probably just don't understand
> how lpm would be coded in practice.  Am I looking in the right place?  Can
> someone give me a clue about how this works?

route.c is the routing cache, it caches prefix based lookup results
so that a direct hash based lookup can be used for subsequent lookups
on the same exact key.

The prefix based lookup occurs in fib_hash.c, it uses 32+1 hash tables
to implement the prefix based lookup, one for each bit in the IPV4 address
plus an extra for "default" routes requiring matching of no bits.  The
hash tables are lookup up from most specific to least specific so that
we truly get a longest matching prefix lookup.

Any time the routing tables are changed, the routing cache in route.c
is flushed completely.
