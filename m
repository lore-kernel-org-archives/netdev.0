From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ovs: do not allocate memory from offline numa node
Date: Mon, 05 Oct 2015 06:44:51 -0700 (PDT)
Message-ID: <20151005.064451.2162263446408087981.davem@davemloft.net>
References: <20151002101822.12499.27658.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, pshelar@nicira.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, vbabka@suse.cz, linux-mm@kvack.org
To: khlebnikov@yandex-team.ru
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20151002101822.12499.27658.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Fri, 02 Oct 2015 13:18:22 +0300

> When openvswitch tries allocate memory from offline numa node 0:
> stats = kmem_cache_alloc_node(flow_stats_cache, GFP_KERNEL | __GFP_ZERO, 0)
> It catches VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid))
> [ replaced with VM_WARN_ON(!node_online(nid)) recently ] in linux/gfp.h
> This patch disables numa affinity in this case.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Applied, but this should probably use NUMA_NO_NODE unconditionally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
