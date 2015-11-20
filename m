From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 04/14] net: tcp_memcontrol: remove bogus hierarchy
 pressure propagation
Date: Fri, 20 Nov 2015 12:07:25 +0300
Message-ID: <20151120090725.GW31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-5-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, Andrew Morton
	<akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko
	<mhocko@suse.cz>, <netdev@vger.kernel.org>, <linux-mm@kvack.org>,
	<cgroups@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Johannes Weiner <hannes@cmpxchg.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1447371693-25143-5-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 12, 2015 at 06:41:23PM -0500, Johannes Weiner wrote:
> When a cgroup currently breaches its socket memory limit, it enters
> memory pressure mode for itself and its *ancestors*. This throttles
> transmission in unrelated sibling and cousin subtrees that have
> nothing to do with the breached limit.
> 
> On the contrary, breaching a limit should make that group and its
> *children* enter memory pressure mode. But this happens already,
> albeit lazily: if an ancestor limit is breached, siblings will enter
> memory pressure on their own once the next packet arrives for them.

Hmm, we still call sk_prot->enter_memory_pressure, which might hurt a
workload in the root cgroup AFAICS. Strange. You fix it in patch 8
though.

> 
> So no additional hierarchy code is needed. Remove the bogus stuff.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
