From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 09/14] net: tcp_memcontrol: simplify linkage between
 socket and page counter
Date: Fri, 20 Nov 2015 15:42:16 +0300
Message-ID: <20151120124216.GD31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-10-git-send-email-hannes@cmpxchg.org>
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
In-Reply-To: <1447371693-25143-10-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 12, 2015 at 06:41:28PM -0500, Johannes Weiner wrote:
> There won't be any separate counters for socket memory consumed by
> protocols other than TCP in the future. Remove the indirection and

I really want to believe you're right. And with vmpressure propagation
implemented properly you are likely to be right.

However, we might still want to account other socket protos to
memcg->memory in the unified hierarchy, e.g. UDP, or SCTP, or whatever
else. Adding new consumers should be trivial, but it will break the
legacy usecase, where only TCP sockets are supposed to be accounted.
What about adding a check to sock_update_memcg() so that it would enable
accounting only for TCP sockets in case legacy hierarchy is used?

For the same reason, I think we'd better rename memcg->tcp_mem to
something like memcg->sk_mem or we can even drop the cg_proto struct
altogether embedding its fields directly to mem_cgroup struct.

Also, I don't see any reason to have tcp_memcontrol.c file. It's tiny
and with this patch it does not depend on tcp code any more. Let's move
it to memcontrol.c?

Other than that this patch looks OK to me.

Thanks,
Vladimir

> link sockets directly to their owning memory cgroup.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
