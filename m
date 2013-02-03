From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] cxgb4: Send Flush Work Request on a TX
 Queue
Date: Sat, 02 Feb 2013 23:04:46 -0500 (EST)
Message-ID: <20130202.230446.1136757468633811792.davem@davemloft.net>
References: <1359641187-17902-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, dm@chelsio.com,
	leedom@chelsio.com, abhishek@chelsio.com, jay@chelsio.com
To: vipul@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54689 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681Ab3BCEEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2013 23:04:48 -0500
In-Reply-To: <1359641187-17902-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul@chelsio.com>
Date: Thu, 31 Jan 2013 19:36:26 +0530

> Send Flush Work Request on a TX Queue if it has unreclaimed TX Descriptors
> and the last time anything was sent on the associated net device was more than
> 5 seconds in the past, issue a flush request on the TX Queue in order to get
> any stranded skb's off the TX Queue.
> 
> Signed-off-by: Jay Hernandez <jay@chelsio.com>
> Signed-off-by: Vipul Pandya <vipul@chelsio.com>

Is the "TX finished" event reporting mechanism supported by this chip
so broken that you cannot use that instead?

Timers and deferred logic to reclaim TX entries is terrible for the
Linux stack.  It means that socket reclaim is delayed, it means that
you really cannot support byte queue limits, it means that TCP Small
Queues won't work properly, it means that packet schedulers can
measure traffic in a wildly inaccurate manner, and so on and so forth.

I'd rather you guys fix these TX reclaim issues properly, rather
than continuing to paper over them with hacks.  A 5 second delay
on TX packet reclaim is absolutely not acceptable.

I'm not applying these two patches, sorry.
