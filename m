From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V2 0/3] net: mitigating kmem_cache free
 slowpath
Date: Thu, 11 Feb 2016 11:59:58 -0500 (EST)
Message-ID: <20160211.115958.619724929941930296.davem@davemloft.net>
References: <20160207.142526.1252110536030712971.davem@davemloft.net>
	<20160208121328.8860.67014.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
 akpm@linux-foundation.org, tom@herbertland.com, alexander.duyck@gmail.com,
 alexei.starovoitov@gmail.com, linux-mm@kvack.org, cl@linux.com
To: brouer@redhat.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160208121328.8860.67014.stgit@localhost>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 08 Feb 2016 13:14:54 +0100

> This patchset is the first real use-case for kmem_cache bulk _free_.
> The use of bulk _alloc_ is NOT included in this patchset. The full use
> have previously been posted here [1].
> 
> The bulk free side have the largest benefit for the network stack
> use-case, because network stack is hitting the kmem_cache/SLUB
> slowpath when freeing SKBs, due to the amount of outstanding SKBs.
> This is solved by using the new API kmem_cache_free_bulk().
> 
> Introduce new API napi_consume_skb(), that hides/handles bulk freeing
> for the caller.  The drivers simply need to use this call when freeing
> SKBs in NAPI context, e.g. replacing their calles to dev_kfree_skb() /
> dev_consume_skb_any().
> 
> Driver ixgbe is the first user of this new API.
> 
> [1] http://thread.gmane.org/gmane.linux.network/384302/focus=397373

Series applied, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
