From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net] tcp: metrics: Avoid duplicate entries with the same
 destination-IP
Date: Wed, 15 Jan 2014 12:18:56 -0800 (PST)
Message-ID: <20140115.121856.712581760900022040.davem@davemloft.net>
References: <1389626736-3143-1-git-send-email-christoph.paasch@uclouvain.be>
	<1389631669.31367.221.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38595 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbaAOUS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 15:18:57 -0500
In-Reply-To: <1389631669.31367.221.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 13 Jan 2014 08:47:49 -0800

> On Mon, 2014-01-13 at 16:25 +0100, Christoph Paasch wrote:
> 
>> Another solution might be to leave tcp_get_metrics() as it is, and in
>> tcpm_new do another call to __tcp_get_metrics() while holding the
>> spin-lock. We would then check __tcp_get_metrics twice for new entries
>> but we won't hold the spin-lock needlessly anymore.
> 
> This is the only solution if you want to fix this.
> Cost of lookup are the cache line misses.
> Avoiding the spinlock is a must.
> 
> The second 'lookup' is basically free, as the first one have populated
> cpu caches.

Indeed, taking the lock in tcp_get_metrics() is to be avoided at all
costs.
