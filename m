From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: 15 Aug 2006 10:08:23 +0200
Message-ID: <p738xlqa0aw.fsf@verdi.suse.de>
References: <20060814110359.GA27704@2ka.mipt.ru>
	<20060815002724.a635d775.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56754 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S965288AbWHOIIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 04:08:34 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060815002724.a635d775.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> writes:
> 
> There will be heaps of cacheline pingpong accessing these arrays.  I'd have
> though that
> 
> static struct whatever {
> 	avl_t avl_node_id;
> 	struct avl_node **avl_node_array;
> 	struct list_head *avl_container_array;
> 	struct avl_node *avl_root;
> 	struct avl_free_list *avl_free_list_head;
> 	spinlock_t avl_free_lock;
> } __cacheline_aligned_in_smp whatevers[NR_CPUS];
> 
> would be better.

Or even better per cpu data. New global/static NR_CPUS arrays should be really discouraged.

-Andi
