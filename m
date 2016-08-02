From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/2] nvme-rdma: Add handling for connecting to IPv6
	targets
Date: Tue, 2 Aug 2016 14:51:53 +0200
Message-ID: <20160802125153.GC13235@lst.de>
References: <1469950060-18098-1-git-send-email-roland@kernel.org> <1469950060-18098-2-git-send-email-roland@kernel.org> <4acdd466-b8f6-8208-7287-e97dfd45bbf1@grimberg.me> <33dfc646-1804-363e-4d83-1ba618303dbb@grimberg.me> <20160801110956.GI16141@lst.de> <e6e54d3f-c6ee-2057-d4e5-13981cd95140@grimberg.me> <20160801155036.GC22771@lst.de> <CAG4TOxPNnUKWeh7FUY8YB127sx8yMu41FuP4hxUMCan_HWQmVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, Sagi Grimberg <sagi@grimberg.me>,
	Jens Axboe <axboe@fb.com>, linux-nvme@lists.infradead.org,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	netdev@vger.kernel.org
To: Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:58827 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965485AbcHBMwG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:52:06 -0400
Content-Disposition: inline
In-Reply-To: <CAG4TOxPNnUKWeh7FUY8YB127sx8yMu41FuP4hxUMCan_HWQmVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 01, 2016 at 09:06:07AM -0700, Roland Dreier wrote:
> On Mon, Aug 1, 2016 at 8:50 AM, Christoph Hellwig <hch@lst.de> wrote:
> > It'd still need all the scope ID handling similar to what Roland did,
> > and that's a fair chunk of code.  We have a few options to handle the
> > different allowed addresses:
> >
> >  (1) v4/v6 only flags
> >  (2) having low-level v4/v6 handlers and one that tries these both
> >  (3) using the try both handler and rejecting the wrong one after
> >      parsing.
> >
> > (3) seems easiest, but (2) sounds fine to me.  But I'd really like to
> > hear from folks on the netdev list what they think of that idea first.
> 
> I think adding a new helper that parses both v4 and v6 addresses +
> scope ID seems like the best thing for now.  I did a grep for in6_pton
> and it looks like at least fs/cifs/netmisc.c and net/sunrpc/addr.c
> could use the helper.
> 
> What do you think of adding inet_pton_with_scope() to
> net/core/utils.c?  I'm open to better ideas on the name.  But I can
> code that up and use it in nvme, as well as convert over the two
> places I mentioned above.  The first parameter of the function can be
> an af, and the caller can pass in AF_UNSPEC, AF_INET, or AF_INET6 to
> restrict the parsing to one type of address (or not).

Sounds fine to me, and I hope the netdev folks (Cc'ed) are fine with
that as well.
