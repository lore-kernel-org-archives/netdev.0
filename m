From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/13] mm: memcontrol: hook up vmpressure to socket
 pressure
Date: Wed, 25 Nov 2015 11:30:48 -0500 (EST)
Message-ID: <20151125.113048.45218641761530031.davem@davemloft.net>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
	<20151124215940.GB1373@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.cz,
 tj@kernel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org,
 linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
 kernel-team@fb.com
To: hannes@cmpxchg.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20151124215940.GB1373@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue, 24 Nov 2015 16:59:40 -0500

> Let the networking stack know when a memcg is under reclaim pressure
> so that it can clamp its transmit windows accordingly.
> 
> Whenever the reclaim efficiency of a cgroup's LRU lists drops low
> enough for a MEDIUM or HIGH vmpressure event to occur, assert a
> pressure state in the socket and tcp memory code that tells it to curb
> consumption growth from sockets associated with said control group.
> 
> Traditionally, vmpressure reports for the entire subtree of a memcg
> under pressure, which drops useful information on the individual
> groups reclaimed. However, it's too late to change the userinterface,
> so add a second reporting mode that reports on the level of reclaim
> instead of at the level of pressure, and use that report for sockets.
> 
> vmpressure events are naturally edge triggered, so for hysteresis
> assert socket pressure for a second to allow for subsequent vmpressure
> events to occur before letting the socket code return to normal.
> 
> This will likely need finetuning for a wider variety of workloads, but
> for now stick to the vmpressure presets and keep hysteresis simple.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
