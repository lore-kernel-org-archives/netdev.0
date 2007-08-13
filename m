From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: Distributed storage.
Date: Mon, 13 Aug 2007 09:45:30 +0200
Message-ID: <20070813074530.GE23758@kernel.dk>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708071124.56859.phillips@phunq.net> <20070807205538.GB5245@kernel.dk> <200708121637.00144.phillips@phunq.net> <20070813072848.GC23758@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:8485 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968048AbXHMHpd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 03:45:33 -0400
Content-Disposition: inline
In-Reply-To: <20070813072848.GC23758@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 13 2007, Jens Axboe wrote:
> > You did not comment on the one about putting the bio destructor in 
> > the ->endio handler, which looks dead simple.  The majority of cases 
> > just use the default endio handler and the default destructor.  Of the 
> > remaining cases, where a specialized destructor is needed, typically a 
> > specialized endio handler is too, so combining is free.  There are few 
> > if any cases where a new specialized endio handler would need to be 
> > written.
> 
> We could do that without too much work, I agree.

But that idea fails as well, since reference counts and IO completion
are two completely seperate entities. So unless end IO just happens to
be the last user holding a reference to the bio, you cannot free it.

-- 
Jens Axboe

