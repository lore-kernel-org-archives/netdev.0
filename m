From: Steven Blake <slblake@petri-meat.com>
Subject: Re: Move fib_alias out of fib_hash.c
Date: Wed, 29 Sep 2004 17:20:43 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096492842.2344.57.camel@localhost.localdomain>
References: <20040928214722.11aef8e0.davem@davemloft.net>
	 <16730.53965.503605.943263@robur.slu.se>
	 <20040929125359.12a00ba7.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040929125359.12a00ba7.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-09-29 at 15:53, David S. Miller wrote:

> On Wed, 29 Sep 2004 17:20:45 +0200
> Robert Olsson <Robert.Olsson@data.slu.se> wrote:
> 
> >   we can interface new lookups cleanly. For a trie something like:
> 
> You are already making a critical logic error.
> 
> You cannot find the longest matching prefix and just use that.
> 
> Rather, you must iterate through all matching prefixes in the
> table from longest to shortest, trying fib_semantic_match() on
> each one until it says OK.
> 
> If you don't do that, then you're not providing the same behavior
> of the current code.  If next hops go down, you have to try the
> next longest matching prefix and so on and so forth.

I'm not criticizing the current design, but it is very typical of
routers to put the burden of fixing up the FIB in the event of a
next-hop state change on the routing daemon, and not the dataplane.
Which is one reason why having a FIB datastructure that can be updated
very efficiently is important.

> It can also
> be the case that the longest matching prefix entry has no matching
> TOS key, whereas a shorter prefix does.

No routing protocols are distributing TOS-specific routes, and there is
no prospect of that feature ever coming back.  Why pay the cost of
matching TOS on every packet forwarded?


Regards,

// Steve
