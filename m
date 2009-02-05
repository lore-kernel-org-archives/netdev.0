From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Deadlock with icmpv6fuzz
Date: Thu, 05 Feb 2009 14:24:02 -0800
Message-ID: <adafxisjzel.fsf@cisco.com>
References: <20090126.213112.197185044.davem@davemloft.net>
	<20090127075356.GA6255@alice>
	<20090128093507.GA15956@gondor.apana.org.au>
	<20090129.174954.263448549.davem@davemloft.net>
	<20090205130149.GA28152@gondor.apana.org.au>
	<20090205143143.GA18734@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Eric Sesterhenn <snakebyte@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:52513 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782AbZBEWYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 17:24:05 -0500
In-Reply-To: <20090205143143.GA18734@alice> (Eric Sesterhenn's message of
	"Thu, 5 Feb 2009 15:31:43 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > [ 2880.044328] icmpv6fuzz: page allocation failure. order:9, mode:0x40d0
 > [ 2880.044495] Pid: 10968, comm: icmpv6fuzz Not tainted
 > 2.6.29-rc3-00580-ga2fe994-dirty #239
 > [ 2880.044694] Call Trace:
 > [ 2880.044802]  [<c016886a>] __alloc_pages_internal+0x38e/0x3aa
 > [ 2880.044954]  [<c016889a>] __get_free_pages+0x14/0x24
 > [ 2880.071336]  [<c018412c>] __kmalloc+0x2e/0x122
 > [ 2880.071589]  [<c06fa227>] ipv6_flowlabel_opt+0x1e0/0x7b1
 > [ 2880.092922]  [<c06e8c9e>] ipv6_setsockopt+0xa0f/0xb89

>From a quick scan of the code, it looks as if optlen is never sanity
checked in the case of setsockopt(IPV6_FLOWLABEL_MGR), and
ipv6_flowlabel_opt() calls into fl_create() with whatever value
userspace passes in, which then pretty much does kmalloc(optlen).
So if icmpv6fuzz passes some big random value, it can cause this failure.

I don't know what the appropriate limit should be, so no patch, sorry.

 - R.
