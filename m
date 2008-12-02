From: David Miller <davem@davemloft.net>
Subject: Re: net-next: lockdep complains re percpu counters
Date: Mon, 01 Dec 2008 23:37:48 -0800 (PST)
Message-ID: <20081201.233748.204870635.davem@davemloft.net>
References: <20081130130726.GA4365@x200.localdomain>
	<4932C128.6040401@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49951
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751454AbYLBHhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 02:37:47 -0500
In-Reply-To: <4932C128.6040401@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sun, 30 Nov 2008 17:36:56 +0100

> [PATCH] net: percpu_counter_inc() should not be called in BH-disabled section
> 
> I checked all per_cpu_counter_xxx() usages in network tree, and I think
> all call sites are BH enabled except one in inet_csk_listen_stop().
> 
> commit dd24c00191d5e4a1ae896aafe33c6b8095ab4bd1
> (net: Use a percpu_counter for orphan_count)
> replaced atomic_t orphan_count to a percpu_counter.
> 
> atomic_inc()/atomic_dec() can be called from any context, while percpu_counter_xxx()
> should be called from a consistent state.
> 
> For orphan_count, this context can be the BH-enabled one.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

I applied this preemptively even though Alexey hasn't given
test feedback yet, and I also added a mention of his report
in the commit message.

Thanks.
