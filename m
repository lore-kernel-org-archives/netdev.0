From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Mon, 2 Feb 2009 08:08:55 +0000
Message-ID: <20090202080855.GA4129@ff.dom.local>
References: <20090126212130.GA4338@ioremap.net> <20090126.221056.174077798.davem@davemloft.net> <20090127074048.GA4197@ff.dom.local> <20090130.134227.123379239.davem@davemloft.net> <20090130221604.GD11381@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, zbr@ioremap.net, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:4321 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbZBBIJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 03:09:02 -0500
Content-Disposition: inline
In-Reply-To: <20090130221604.GD11381@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 31, 2009 at 09:16:04AM +1100, Herbert Xu wrote:
> On Fri, Jan 30, 2009 at 01:42:27PM -0800, David Miller wrote:
...
> > Back to real life, I think long term the thing to do is to just do the
> > cached page allocator thing we'll be doing after Jarek's socket page
> > patch is integrated, and for best performance the driver has to
> > receive it's data into pages, only explicitly pulling the ethernet
> > header into the linear area, like NIU does.
> 
> Yes that sounds like the way to go.

Looks like a lot of changes in drivers, plus: would it work with jumbo
frames? I wonder why the linear area can't be allocated as paged, and
freed with put_page() instead of kfree(skb->head) in skb_release_data().

Actually, at least for some time, there could be used both of these
methods (on paged alloc failure) with some ifs in skb_release_data()
and spd_fill_page() (to check if linear_to_page() is needed).

Jarek P.
