From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Fri, 18 Jul 2008 20:00:10 +0400
Message-ID: <20080718160009.GA29740@2ka.mipt.ru>
References: <200807171633.49791.opurdila@ixiacom.com> <200807181704.17211.opurdila@ixiacom.com> <20080718143219.GA905@2ka.mipt.ru> <200807181850.07393.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	axboe@kernel.dk
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:34303 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751398AbYGRQAS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 12:00:18 -0400
Content-Disposition: inline
In-Reply-To: <200807181850.07393.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 18, 2008 at 06:50:07PM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> > If there are 20 packets in the queue it will get 16 and put them into
> > another end (in the next call in your example). Where will it block?
> 
> It will take 17 because this is what the user requested. And when trying to 
> push the 17th on the pipe, it will block. I base this both on experiments and 
> on my understanding of the tcp splice receive implementation. 

Seems like we do not understand each other. How it can take 17 if there
are only 16 pages? By 'push' you mean splice-into-pipe or
splice-out-of-pipe-into-other-fd? Where exactly will it block?

> > Btw, you are also trying to change existing userspace API, which may be
> > very much forbidden at this stage.
> 
> If people here will be telling me that for splice you must always use 
> non-blocking I/O since you can't get the blocking case to work reliably, than 
> I will accept that. After all, they know better :) 

It may be not because of how is right or wrong, but that some userspace
can already rely on existing behaviour of the flag, and changing it
(even to more correct) may break some application in a really
non-trivial way.

-- 
	Evgeniy Polyakov
