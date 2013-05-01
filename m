From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] netpoll: convert mutex into a semaphore
Date: Wed, 01 May 2013 15:00:59 -0400 (EDT)
Message-ID: <20130501.150059.785741895635621733.davem@davemloft.net>
References: <20130429181322.GA27119@hmsreliant.think-freely.org>
	<1367336105-6275-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bvanassche@acm.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41653 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755512Ab3EATBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 15:01:01 -0400
In-Reply-To: <1367336105-6275-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 30 Apr 2013 11:35:05 -0400

> Bart Van Assche recently reported a warning to me:
 ...
> This resulted from my commit ca99ca14c which introduced a mutex_trylock
> operation in a path that could execute in interrupt context.  When mutex
> debugging is enabled, the above warns the user when we are in fact
> exectuting in interrupt context
> interrupt context.
> 
> After some discussion, It seems that a semaphore is the proper mechanism to use
> here.  While mutexes are defined to be unusable in interrupt context, no such
> condition exists for semaphores (save for the fact that the non blocking api
> calls, like up and down_trylock must be used when in irq context).
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Bart Van Assche <bvanassche@acm.org>

Neil this looks good to me so I'm going to toss it into my tree and queue
it up for -stable too, thanks!
