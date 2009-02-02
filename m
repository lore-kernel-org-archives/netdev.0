From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Mon, 2 Feb 2009 08:43:58 +0000
Message-ID: <20090202084358.GB4129@ff.dom.local>
References: <20090130.134227.123379239.davem@davemloft.net> <20090130221604.GD11381@gondor.apana.org.au> <20090202080855.GA4129@ff.dom.local> <20090202.001854.261399333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, zbr@ioremap.net, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:17155 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbZBBIoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 03:44:05 -0500
Content-Disposition: inline
In-Reply-To: <20090202.001854.261399333.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 02, 2009 at 12:18:54AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 2 Feb 2009 08:08:55 +0000
> 
> > On Sat, Jan 31, 2009 at 09:16:04AM +1100, Herbert Xu wrote:
> > > On Fri, Jan 30, 2009 at 01:42:27PM -0800, David Miller wrote:
> > ...
> > > > Back to real life, I think long term the thing to do is to just do the
> > > > cached page allocator thing we'll be doing after Jarek's socket page
> > > > patch is integrated, and for best performance the driver has to
> > > > receive it's data into pages, only explicitly pulling the ethernet
> > > > header into the linear area, like NIU does.
> > > 
> > > Yes that sounds like the way to go.
> > 
> > Looks like a lot of changes in drivers, plus: would it work with jumbo
> > frames? I wonder why the linear area can't be allocated as paged, and
> > freed with put_page() instead of kfree(skb->head) in skb_release_data().
> 
> Allocating 4096 or 8192 bytes for a 1500 byte frame is wasteful.

I mean allocating chunks of cached pages similarly to sk_sndmsg_page
way. I guess the similar problem is to be worked out in any case. But
it seems doing it on the linear area requires less changes in other
places.

Jarek P.
