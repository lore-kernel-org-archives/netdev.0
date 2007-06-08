From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive
Date: Fri, 8 Jun 2007 10:38:53 +0200
Message-ID: <20070608083853.GH7341@kernel.dk>
References: <20070607105159.GV4735@kernel.dk> <20070607145818.GA26491@2ka.mipt.ru> <20070608074823.GG7341@kernel.dk> <20070608.010629.52902577.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:9234 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932842AbXFHIk3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 04:40:29 -0400
Content-Disposition: inline
In-Reply-To: <20070608.010629.52902577.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 08 2007, David Miller wrote:
> From: Jens Axboe <jens.axboe@oracle.com>
> Date: Fri, 8 Jun 2007 09:48:24 +0200
> 
> > Perhaps it's possible to solve this at a different level - can we hang
> > on to the skb until the pipe buffer has been consumed, and prevent reuse
> > that way? Then we don't have to care what backing the skb has, as long
> > as it (and its data) isn't being reused until we drop the reference to
> > it in sock_pipe_buf_release().
> 
> Depending upon whether the pipe buffer consumption is bounded of not,
> this will jam up the TCP sender because the SKB data allocation is
> charged against the socket send buffer allocation.

Forgive my network ignorance, but is that a problem? Since you bring it
up, I guess so :-)

We can grow the pipe, should we have to. So instead of blocking waiting
on reader consumption, we can extend the size of the pipe and keep
going.

-- 
Jens Axboe

