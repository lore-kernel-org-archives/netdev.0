From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [take 2] Fix for the fundamental network/block layer race in sendfile().
Date: Wed, 9 Apr 2008 13:33:21 +0200
Message-ID: <20080409113321.GK12774@kernel.dk>
References: <20080328092036.GA11924@2ka.mipt.ru> <20080328.134053.122172549.davem@davemloft.net> <20080328205613.GA24812@2ka.mipt.ru> <20080328.140736.92315090.davem@davemloft.net> <20080328215131.GB24812@2ka.mipt.ru> <20080401164904.GA2382@2ka.mipt.ru> <20080408122545.GA31729@2ka.mipt.ru> <47FB6C03.3070708@cosmosbay.com> <20080408172652.GA4877@2ka.mipt.ru> <20080408213054.GA8791@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:3290 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752864AbYDILd0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 07:33:26 -0400
Content-Disposition: inline
In-Reply-To: <20080408213054.GA8791@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 09 2008, Evgeniy Polyakov wrote:
> On Tue, Apr 08, 2008 at 09:26:52PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > >    Unless I mistaken, you store in page->lru.next some info to find 
> > > your pipe pointer, assuming it is unique for this page.
> > > 
> > > What happens if two threads are doing a splice()/sendfile() using the 
> > > same underlying (source) file (and same pages in this file)
> > 
> > Page will be referenced twice (for each thread) and each thread will
> > have own pipe_inode_info structure, so each one will sleep on own wait
> > queue and will be awakened separately, where its release counter will be
> > dropped.
> 
> I was wrong, here will be a problem - page can be shared between multiple
> threads, since it is unlocked after putting it into page cache, so it is
> not allowed to put into it some per-thread private data.

Threads or not, it does not matter. Even simpler, the same page could be
in multiple pipes. So that trick definitely will not work at all.

-- 
Jens Axboe

