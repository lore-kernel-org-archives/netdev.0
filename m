From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/14] net: tcp_memcontrol: remove bogus hierarchy
 pressure propagation
Date: Fri, 13 Nov 2015 11:00:26 -0500 (EST)
Message-ID: <20151113.110026.2097026445648423318.davem@davemloft.net>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
	<1447371693-25143-5-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org,
	mhocko@suse.cz, netdev@vger.kernel.org, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: hannes@cmpxchg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932229AbbKMQA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 11:00:28 -0500
In-Reply-To: <1447371693-25143-5-git-send-email-hannes@cmpxchg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Thu, 12 Nov 2015 18:41:23 -0500

> When a cgroup currently breaches its socket memory limit, it enters
> memory pressure mode for itself and its *ancestors*. This throttles
> transmission in unrelated sibling and cousin subtrees that have
> nothing to do with the breached limit.
> 
> On the contrary, breaching a limit should make that group and its
> *children* enter memory pressure mode. But this happens already,
> albeit lazily: if an ancestor limit is breached, siblings will enter
> memory pressure on their own once the next packet arrives for them.
> 
> So no additional hierarchy code is needed. Remove the bogus stuff.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David S. Miller <davem@davemloft.net>
