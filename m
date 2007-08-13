From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Block device throttling [Re: Distributed storage.]
Date: Mon, 13 Aug 2007 12:14:41 +0400
Message-ID: <20070813081441.GA30089@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <20070808095448.GA3440@2ka.mipt.ru> <200708122236.24096.phillips@phunq.net> <200708122344.00343.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42789 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967511AbXHMIPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 04:15:17 -0400
Content-Disposition: inline
In-Reply-To: <200708122344.00343.phillips@phunq.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 12, 2007 at 11:44:00PM -0700, Daniel Phillips (phillips@phunq.net) wrote:
> On Sunday 12 August 2007 22:36, I wrote:
> > Note!  There are two more issues I forgot to mention earlier.
> 
> Oops, and there is also:
> 
> 3) The bio throttle, which is supposed to prevent deadlock, can itself 
> deadlock.  Let me see if I can remember how it goes.
> 
>   * generic_make_request puts a bio in flight
>   * the bio gets past the throttle and initiates network IO
>   * net calls sk_alloc->alloc_pages->shrink_caches
>   * shrink_caches submits a bio recursively to our block device
>   * this bio blocks on the throttle
>   * net may never get the memory it needs, and we are wedged

If system is in such condition, it is already broken - throttle limit
must be lowered (next time) not to allow such situation.

-- 
	Evgeniy Polyakov
