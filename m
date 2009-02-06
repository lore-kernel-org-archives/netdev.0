From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Fri, 06 Feb 2009 01:17:22 -0800 (PST)
Message-ID: <20090206.011722.41272682.davem@davemloft.net>
References: <20090203094108.GA4639@ff.dom.local>
	<20090205.235258.257422341.davem@davemloft.net>
	<20090206091034.GA4879@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, zbr@ioremap.net, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47499
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752889AbZBFJR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 04:17:26 -0500
In-Reply-To: <20090206091034.GA4879@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 6 Feb 2009 09:10:34 +0000

> Hmm... I don't get it. It seems these slabs do a lot of advanced work,
> and still some people like Evgeniy or Nick thought it's not enough,
> and even found it worth of their time to rework this.

Note that, at least to some extent, the memory allocators are
duplicating some of the locality and NUMA logic that's already present
in the page allocator itself.

Except that they are handling the fact that objects are moving around
instead of pages.

Also keep in mind that we might also want to encourage drivers to make
use of the SKB recycling mechanisms we have.  So this will decrease
lifetimes, and thus the wastage and locality issues immensely.

We truly want something different from what the general purpose
allocator provides.  Namely, a reference countable buffer.

And all I'm saying is that since the page allocator provides that
facility, and using pages solves all of the splice() et al.  problems,
building something extremely simple on top of the page allocator seems
to be a good way to go.
