From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Mon, 02 Feb 2009 00:18:54 -0800 (PST)
Message-ID: <20090202.001854.261399333.davem@davemloft.net>
References: <20090130.134227.123379239.davem@davemloft.net>
	<20090130221604.GD11381@gondor.apana.org.au>
	<20090202080855.GA4129@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, zbr@ioremap.net, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52659
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751384AbZBBIS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 03:18:57 -0500
In-Reply-To: <20090202080855.GA4129@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 2 Feb 2009 08:08:55 +0000

> On Sat, Jan 31, 2009 at 09:16:04AM +1100, Herbert Xu wrote:
> > On Fri, Jan 30, 2009 at 01:42:27PM -0800, David Miller wrote:
> ...
> > > Back to real life, I think long term the thing to do is to just do the
> > > cached page allocator thing we'll be doing after Jarek's socket page
> > > patch is integrated, and for best performance the driver has to
> > > receive it's data into pages, only explicitly pulling the ethernet
> > > header into the linear area, like NIU does.
> > 
> > Yes that sounds like the way to go.
> 
> Looks like a lot of changes in drivers, plus: would it work with jumbo
> frames? I wonder why the linear area can't be allocated as paged, and
> freed with put_page() instead of kfree(skb->head) in skb_release_data().

Allocating 4096 or 8192 bytes for a 1500 byte frame is wasteful.
