From: Tommi Virtanen <tv@debian.org>
Subject: Re: [PATCH] Change MAC without bringing interface down
Date: Mon, 18 Aug 2003 17:24:55 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818142455.GA1793@lapdog>
References: <20030818091312.GA4889@lapdog> <20030818041911.358c3437.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030818041911.358c3437.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Aug 18, 2003 at 04:19:11AM -0700, David S. Miller wrote:
> On Mon, 18 Aug 2003 12:13:12 +0300
> > 	1. makes eth_header_cache_update also update the source MAC in
> > 	   hh_cache.
> > 
> > 	2. adds a NETDEV_CHANGEADDR notifier in net/core/neighbour.c
> > 	   that walks through all the neighbour entries and updates
> > 	   the hh_cache's for all the neighbour entries related to
> > 	   given device.
> I would suggest to fix this by instead flushing the hh
> entries (just like neigh_destroy() does).

	This may be a dumb question, but how do I do that?

	If I set them to neigh_blackhole, like neigh_destroy() does,
	e.g. already running gets -ENETDOWN. That's now true and it's
	not nice. I'm having trouble seeing how to "disable" the
	neighbour entry, so it won't be used again.

	If I use neigh_suspect() in an attempt to mark the entry as
	"expired", I see traffic using the "old" MAC as source after a
	while. Apparently, it gets confirmed and then the old MAC
	is used again.

> This way, we don't have to fix up every single header cache
> implementation, that's painful :(

	I agree with that, though I am only interested in ethernet ;)

-- 
:(){ :|:&};:
