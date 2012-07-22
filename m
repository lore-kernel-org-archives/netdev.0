From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] tcp: use seqlock for all cached tcp_metrics
Date: Sun, 22 Jul 2012 12:32:46 -0700 (PDT)
Message-ID: <20120722.123246.864281319907290494.davem@davemloft.net>
References: <1342950268-2380-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416Ab2GVTcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 15:32:47 -0400
In-Reply-To: <1342950268-2380-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 22 Jul 2012 12:44:28 +0300

> 	The ability to reclaim existing cache entries
> requires metrics to be accessed with additional seqlock.
> fastopen_cache tried to provide such locking for its values
> but there is always the risk to access reclaimed entry.

I basically claim that accidental use of reclaimed entries
is completely harmless for everything other than fastopen.

Therefore I do not advocate adding the new overhead and complexity for
the non-fastopen cases.  It should be a completely free, lockless, and
synchornization free cache.  If we read crap metrics, so be it, maybe
the network dynamics changed to the same amount, and we would never
know the different.  Therefore, it doesn't really matter if we read
crap values for these measurements.

Thanks.
