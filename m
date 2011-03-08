From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/4] slub,rcu: don't assume the size of struct rcu_head
Date: Tue, 8 Mar 2011 12:25:41 -0600 (CST)
Message-ID: <alpine.DEB.2.00.1103081224550.25214@router.home>
References: <4D6CA852.3060303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>,
  "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
  Pekka Enberg <penberg@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
  "David S. Miller" <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>,
  linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4D6CA852.3060303@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Mar 2011, Lai Jiangshan wrote:

> -		 * RCU free overloads the RCU head over the LRU
> -		 */
> -		struct rcu_head *head = (void *)&page->lru;
> +		struct rcu_head *head;
> +
> +		if (need_reserve_slab_rcu) {
> +			int order = compound_order(page);
> +			int offset = (PAGE_SIZE << order) - s->reserved;
> +
> +			BUG_ON(s->reserved != sizeof(*head));

VM_BUG_ON is sufficient here I think.

Otherwise

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
