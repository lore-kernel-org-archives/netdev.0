From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sock: deduplicate errqueue dequeue
Date: Mon, 01 Sep 2014 21:49:53 -0700 (PDT)
Message-ID: <20140901.214953.1483394533495236.davem@davemloft.net>
References: <1409535027-16963-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbaIBEty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 00:49:54 -0400
In-Reply-To: <1409535027-16963-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Sun, 31 Aug 2014 21:30:27 -0400

> sk->sk_error_queue is dequeued in four locations. All share the
> exact same logic. Deduplicate.
> 
> Also collapse the two critical sections for dequeue (at the top of
> the recv handler) and signal (at the bottom).
> 
> This moves signal generation for the next packet forward, which should
> be harmless.
> 
> It also changes the behavior if the recv handler exits early with an
> error. Previously, a signal for follow-up packets on the errqueue
> would then not be scheduled. The new behavior, to always signal, is
> arguably a bug fix.
> 
> For rxrpc, the change causes the same function to be called repeatedly
> for each queued packet (because the recv handler == sk_error_report).
> It is likely that all packets will fail for the same reason (e.g.,
> memory exhaustion).
> 
> This code runs without sk_lock held, so it is not safe to trust that
> sk->sk_err is immutable inbetween releasing q->lock and the subsequent
> test. Introduce int err just to avoid this potential race.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks.
