From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Sun, 08 Jun 2003 22:38:25 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030608.223825.104049415.davem@redhat.com>
References: <20030608.050500.28795668.davem@redhat.com>
	<874r30r9z2.fsf@deneb.enyo.de>
	<20030608234926.GA9453@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: sim@netnation.com
In-Reply-To: <20030608234926.GA9453@netnation.com>
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Sun, 8 Jun 2003 16:49:26 -0700

   On Sun, Jun 08, 2003 at 03:10:25PM +0200, Florian Weimer wrote:
   
   > Further parameters which could be tweaked is the kind of adjacency
   > information (where to store the L2 information, whether to include the
   > prefix length in the adjacency record etc.).
   
   What is the problem with the current approach?  Does the overhead come
   from having to iterate through the hashes for each prefix?

It comes from doing the slow path, which actually had a bug
(wouldn't grow the hash tables past a certain point).

I bet most of Florian's performance problems go away if he
runs with the fib_hash fix that I put into the tree.

In fact, the current slow path is _OPTIMAL_ for any sane routing
table.  The lookups are exactly O(n_prefixes) where n_prefixes
in the number of unique subnet prefixes you've added to your routing
table.

This is precisely the same complexity as you'd get with a trie based
approach with guarenteed depth not exceeding 32.

I think most people are unaware of how the slow path we have actually
works.

The place I see bugs are in routing cache GC operation, it can't keep
up with how fast we can create new routing cache entries, and this
is merely because it isn't tuned not because it is not capable of
keeping equilibrium properly.

This is why I really wish Florian would explore this area instead
of ripping the whole thing apart :-)
