From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Tue, 15 Feb 2005 21:47:23 +0100
Message-ID: <20050215204723.GM31837@postel.suug.ch>
References: <1106576005.1652.1292.camel@jzny.localdomain> <20050124150634.GT23931@postel.suug.ch> <1106747313.1107.7.camel@jzny.localdomain> <1108134446.5523.22.camel@ganymede> <1108215923.1126.132.camel@jzny.localdomain> <1108246033.7554.18.camel@ganymede> <20050212223204.GG31837@postel.suug.ch> <1108340618.14978.66.camel@ganymede> <20050214142710.GI31837@postel.suug.ch> <1108499294.5465.22.camel@ganymede>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
To: Dan Siemon <dan@coverfire.com>
Content-Disposition: inline
In-Reply-To: <1108499294.5465.22.camel@ganymede>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Perhaps we could agree on a single API for the low-level message parsing
> and netlink message construction.  At least then we would not be
> duplicating bug-fixes in our netlink code.

Sure, I think they're quite similiar. I abstracted the netlink message
and routing attributes building a bit and added some bits for
simplification.

http://people.suug.ch/~tgr/libnl/doc/group__msg.html
http://people.suug.ch/~tgr/libnl/doc/group__rtattr.html

I do not care what to use though as long as it is easy to use.

> Whether or not this sharing would be useful probably depends on if you
> would continue to maintain your own non-GObject APIs for the various
> QDiscs and classifiers.  GObject makes the creation and maintenance of
> the language bindings much easier so its basically necessary for my
> goals.

I see, well I can extend my objects, I'm even willing to change the
architecture if needed. The only requirements from my side is to
keep the generic caching header to allow putting these objects into
generic caches and keep it simple to readd commit/rollback extesions
later on.

What is exactly required to make it GObject aware? I've never worked
with GOBject so far. Basically a qdisc looks like this at the moment:

struct rtnl_qdisc
{
	NLHDR_COMMON;		/* common fields required by cache */
	NL_TCA_GENERIC(q);	/* generic tc fields (parent, handle, ifindex ...) */
	void *opts;		/* qdisc specific options (e.g.  rtnl_sch_fifo) */
};

The NLHDR_COMMON must stay first, the ordering of the others doesn't
matter.

> I'm willing to switch the underlying implementation of LQL to use your
> more featureful NL implementation if that means there won't be two
> competing C APIs to the individual QDiscs etc.

It would be nice if we find a way to integrate both without losing the
features of any side.
