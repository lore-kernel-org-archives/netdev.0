From: Patrick McHardy <kaber@trash.net>
Subject: Re: Ottawa and slow hash-table resize
Date: Tue, 24 Feb 2015 10:39:18 +0000
Message-ID: <20150224103918.GJ3713@acer.localdomain>
References: <20150223191201.GA4355@cloud>
 <20150223210358.GB806@casper.infradead.org>
 <20150223215248.GA15405@linux.vnet.ibm.com>
 <20150223.173252.397503088215638994.davem@davemloft.net>
 <20150223230619.GD15405@linux.vnet.ibm.com>
 <20150224083714.GB17306@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>, josh@joshtriplett.org,
	alexei.starovoitov@gmail.com, herbert@gondor.apana.org.au,
	ying.xue@windriver.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43436 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbbBXKjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 05:39:24 -0500
Content-Disposition: inline
In-Reply-To: <20150224083714.GB17306@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24.02, Thomas Graf wrote:
> On 02/23/15 at 03:06pm, Paul E. McKenney wrote:
> > On Mon, Feb 23, 2015 at 05:32:52PM -0500, David Miller wrote:
> > > I just did a quick scan of all code paths that do inserts into an
> > > rhashtable, and it seems like all of them can easily block.  So why
> > > don't we do that?  Make inserts sleep on an rhashtable expansion
> > > waitq.
> > > 
> > > There could even be a counter of pending inserts, so the expander can
> > > decide to expand further before waking the inserting threads up.
> > 
> > Should be reasonably simple, and certainly seems worth a try!
> 
> Agreed. Definitely desirable for nft_hash. I like the pending counter
> idea. I'm experimenting with various ideas on blocking inserts for
> Netlink. Blocking too long might open DoS vectors as one app could
> easily delay the creation of sockets for other applications.

Regarding nft_hash, blocking in the netlink path certainly seems fine,
but we will soon also have inserts from the packet processing path,
where we obviously can't block.
