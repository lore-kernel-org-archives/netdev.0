From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] tcp: metrics: Avoid duplicate entries with the
 same destination-IP
Date: Fri, 17 Jan 2014 18:08:09 -0800 (PST)
Message-ID: <20140117.180809.912704380920499561.davem@davemloft.net>
References: <1389898881-11393-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41379 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbaARCIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 21:08:09 -0500
In-Reply-To: <1389898881-11393-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Thu, 16 Jan 2014 20:01:21 +0100

> Because the tcp-metrics is an RCU-list, it may be that two
> soft-interrupts are inside __tcp_get_metrics() for the same
> destination-IP at the same time. If this destination-IP is not yet part of
> the tcp-metrics, both soft-interrupts will end up in tcpm_new and create
> a new entry for this IP.
> So, we will have two tcp-metrics with the same destination-IP in the list.
> 
> This patch checks twice __tcp_get_metrics(). First without holding the
> lock, then while holding the lock. The second one is there to confirm
> that the entry has not been added by another soft-irq while waiting for
> the spin-lock.
> 
> Fixes: 51c5d0c4b169b (tcp: Maintain dynamic metrics in local cache.)
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
> 
> v2: As requested by Eric D.: Check the cache twice. Once without holding the lock,
>     and then again while holding the lock. That way we avoid taking the lock
>     needlessly.

Looks great, applied and queued up for -stable, thanks.
