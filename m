From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/14] net: tcp_memcontrol: properly detect ancestor
 socket pressure
Date: Fri, 13 Nov 2015 11:00:14 -0500 (EST)
Message-ID: <20151113.110014.733581317119133610.davem@davemloft.net>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
	<1447371693-25143-4-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org,
 mhocko@suse.cz, netdev@vger.kernel.org, linux-mm@kvack.org,
 cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com
To: hannes@cmpxchg.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1447371693-25143-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Thu, 12 Nov 2015 18:41:22 -0500

> When charging socket memory, the code currently checks only the local
> page counter for excess to determine whether the memcg is under socket
> pressure. But even if the local counter is fine, one of the ancestors
> could have breached its limit, which should also force this child to
> enter socket pressure. This currently doesn't happen.
> 
> Fix this by using page_counter_try_charge() first. If that fails, it
> means that either the local counter or one of the ancestors are in
> excess of their limit, and the child should enter socket pressure.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
