From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Block device throttling [Re: Distributed storage.]
Date: Mon, 13 Aug 2007 04:04:26 -0700
Message-ID: <200708130404.26572.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708122344.00343.phillips@phunq.net> <20070813081441.GA30089@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl081-085-152.lax1.dsl.speakeasy.net ([64.81.85.152]:59481
	"EHLO moonbase.phunq.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S936278AbXHMLEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 07:04:30 -0400
In-Reply-To: <20070813081441.GA30089@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 13 August 2007 01:14, Evgeniy Polyakov wrote:
> > Oops, and there is also:
> >
> > 3) The bio throttle, which is supposed to prevent deadlock, can
> > itself deadlock.  Let me see if I can remember how it goes.
> >
> >   * generic_make_request puts a bio in flight
> >   * the bio gets past the throttle and initiates network IO
> >   * net calls sk_alloc->alloc_pages->shrink_caches
> >   * shrink_caches submits a bio recursively to our block device
> >   * this bio blocks on the throttle
> >   * net may never get the memory it needs, and we are wedged
>
> If system is in such condition, it is already broken - throttle limit
> must be lowered (next time) not to allow such situation.

Agreed that the system is broken, however lowering the throttle limit 
gives no improvement in this case.

This is not theoretical, but a testable, repeatable result.  
Instructions to reproduce should show up tomorrow.

This bug is now solved in a kludgy way.  Now, Peter's patch set offers a 
much cleaner way to fix this little problem, along with at least one 
other nasty that it already fixed.

Regards,

Daniel
