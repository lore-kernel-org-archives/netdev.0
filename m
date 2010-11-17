From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH net-next 1/4] rtnetlink: Link address family API
Date: Wed, 17 Nov 2010 17:58:14 -0500
Message-ID: <20101117225814.GB17546@canuck.infradead.org>
References: <20101116143014.GA26669@canuck.infradead.org>
 <20101117.113035.229752488.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:43189 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935513Ab0KQW6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 17:58:15 -0500
Content-Disposition: inline
In-Reply-To: <20101117.113035.229752488.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 17, 2010 at 11:30:35AM -0800, David Miller wrote:
> Applied, but note that as-implemented it has the "partial update"
> problem.  When we can't get the af-specific ops for a "parse"
> operation, we just skip that AF yet we let the modifications of
> the other AF's succeed and make it appear to the user that
> everything got updated and all the attributes were consumed.
> 
> I don't know what we can do about this with how things work
> right now.

I absolutely agree and this problem isn't limited to this specific
case at all. All netlink based implementations I am aware of will
silently skip over any unknown attribute type and thus only apply
updates partially.

What I can will do in this specific case is check if all af ops
can be looked up before starting to update things.

Some of the newer netlink interfaces are actually both atomic and
always leave a consistent state. For those which do not I strongly
believe that we should limit inconsistency to a minimum were
possible but leave any kind of fallback mechanism to userspace. I
am experimenting with this in userspace. By listening to
notifications and with the help of sequence numbers it is possible
to reliably switch back to a previous "version" of a link, address,
... even if there are multiple writers.
