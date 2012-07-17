From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Long term PMTU/redirect storage in ipv4.
Date: Tue, 17 Jul 2012 13:46:51 -0700 (PDT)
Message-ID: <20120717.134651.562831385960975623.davem@davemloft.net>
References: <20120717.061418.1893307699868826531.davem@davemloft.net>
	<alpine.LFD.2.00.1207172249270.1831@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756506Ab2GQUq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 16:46:57 -0400
In-Reply-To: <alpine.LFD.2.00.1207172249270.1831@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Tue, 17 Jul 2012 23:41:16 +0300 (EEST)

> 	IIRC, struct fib_info was shared by different
> prefixes. It saves a lot of memory when thousands of
> routes are created to same GW. Now if we end up with 1 or
> 2 fib_info structures for default routes, the nh_exceptions list
> can become very long. May be fib_info is not a good place
> to hide such data.

Your analysis of what fib_info is and how it's intended to
work is accurate.

But we don't use a linked list for the exceptions in the final
version, we use a reclaiming RCU'd hash table like we use for TCP
metrics.

See the updated version of patch #5 and what I actually committed to
net-next.
