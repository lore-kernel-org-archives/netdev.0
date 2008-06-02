From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool -
 e1000/pcnet32
Date: Sun, 1 Jun 2008 23:55:58 -0400
Message-ID: <20080601235558.66e1ed7b.billfink@mindspring.com>
References: <482FBA09.80201@sngx.net>
	<483E0AAE.2020107@sngx.net>
	<20080528221118.63da4092.akpm@linux-foundation.org>
	<483EA2D1.8050603@sngx.net>
	<20080529154525.3916c7b5@core>
	<20080530151250.b44a119a.billfink@mindspring.com>
	<20080531131143.516ca56e@core>
	<20080531195702.0b879dd1.billfink@mindspring.com>
	<20080601014620.GG30769@solarflare.com>
	<20080601164614.012fe1f6.billfink@mindspring.com>
	<20080601222906.GH30769@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	James Cammarata <jimi@sngx.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:35431
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754293AbYFBD4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 23:56:08 -0400
In-Reply-To: <20080601222906.GH30769@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 1 Jun 2008, Ben Hutchings wrote:

> Bill Fink wrote:
> 
> > But the question
> > is how does one devise a generic script or tool that doesn't require
> > any special knowledge of the specific NIC being used.  For example,
> > here's the "ethtool -S" info for my myri10ge NIC:
> > 
> > [root@chance8 ~]# ethtool -S eth2
> > NIC statistics:
> [...]
> >      WC: 1
> >      irq: 8413
> >      MSI: 1
> >      read_dma_bw_MBs: 1398
> >      write_dma_bw_MBs: 1613
> >      read_write_dma_bw_MBs: 2711
> >      serial_number: 287046
> [...]
> >      tx_linearized: 0
> >      link_changes: 8
> >      link_up: 1
> [...]
> > 
> > How does one know which of these reported values are counter stats
> > that one wishes to zero/snapshot, and which are not?
> 
> Ah, I see, I didn't realise some drivers were abusing ethtool stats in
> this way.  But for the most part the differences will show up as zeroes.

I'm not sure I would characterize that as abuse of the ethtool stats,
but rather just a different category of stats.  And I wouldn't want
them to show up as zeros after doing a clear/snapshot of the counter
stats.  The "ethtool -S" output should be completely normal afterward,
with just the counter stats being zeroed.

> If there's really a need for ethtool stats that aren't counters,
> maybe the ethtool API should include flags to indicate which they are.

That would be useful.  Maybe some way of determining the type of an
ethtool stat such as COUNTER (perhaps with subtypes for signed versus
unsigned, 32-bit versus 64-bit), RUNTIME_INFO, etc.

> > Another issue that occurred to me is if multiple people are working
> > on troubleshooting a network problem, how do we insure that they all
> > get a consistent view of the stats?  If this is done via a kernel
> > mechanism then there isn't an issue.  But if it's done via user space,
> > then you have to make sure that everyone zeros/snapshots the stats
> > at the same time.
> > 
> > Ideally, one should be able to do something like "ethtool -z ethX"
> > to zero/snapshot the driver stats, and then "ethtool -S ethX" to get
> > the stats since the last snapshot.  You should be able to use the
> > same tool ("ethtool") to do all of this, and not some other special
> > tool or specially devised homegrown script.  Why make users lives
> > any more difficult than need be?
> 
> No-one's stopping you from adding these options to ethtool.  You could
> have it save statistic sets in, say, /var/run/ethtool.

Yes, that could be done if the ability to determine which ethtool stats
were counter stats was added to the ethtool API.  And I guess they
should be saved in something like /var/run/ethtool/ethX.  But then
what happens when you start using multiple network namespaces, and
for example have eth0 in several different network namespaces.  How
could that be handled, to keep the different network namespaces from
clobbering the stats of another namespace?  If done in the kernel,
I believe it would all work as expected, but it's not clear to me
how to handle this in user space.

						-Bill
