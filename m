From: Flavio Leitner <fleitner@redhat.com>
Subject: Re: [PATCH] niu: fix SMP race protecting rx_rings and tx_rings
Date: Thu, 3 Feb 2011 21:47:48 -0200
Message-ID: <20110203234748.GB3710@redhat.com>
References: <1296758717-18406-1-git-send-email-fleitner@redhat.com>
 <20110203.142145.183054407.davem@davemloft.net>
 <20110203231805.GA3710@redhat.com>
 <20110203.152214.59684545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36710 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221Ab1BCXr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 18:47:56 -0500
Content-Disposition: inline
In-Reply-To: <20110203.152214.59684545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 03, 2011 at 03:22:14PM -0800, David Miller wrote:
> From: Flavio Leitner <fleitner@redhat.com>
> Date: Thu, 3 Feb 2011 21:18:05 -0200
> 
> > Ok, I can write a new version using RCU if you like.
> 
> Don't worry, I'll take care of it, I actually have the
> hardware to test on :-)

Ok. Having the hardware around indeed helps :)

> > I've chose rwsem because I think those operations aren't
> > frequent. The RCU leaves an operation to run later during
> > a safe context, so I thought the cost doesn't worth it.
> 
> One thing I'm worried about with your patch is that the statistics
> method can be called in basically any context, therefore a sleeping
> lock like the rw_semaphore is probably not usable.
> 
> In fact I'm going to revert your patch for now because of this issue.

Oops, I didn't see it there.  I thought all calls there were process
context.  Anyway, RCU then...

thanks for reviewing it,
-- 
Flavio
