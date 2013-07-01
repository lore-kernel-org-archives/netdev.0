From: David Miller <davem@davemloft.net>
Subject: Re: kernel panic in skb_copy_bits
Date: Mon, 01 Jul 2013 13:36:15 -0700 (PDT)
Message-ID: <20130701.133615.366371022223254228.davem@davemloft.net>
References: <51CD0E67.4000008@oracle.com>
	<1372402340.3301.229.camel@edumazet-glaptop>
	<1372412262.3301.251.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe.jin@oracle.com, frank.blaschka@de.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	zheng.x.li@oracle.com, xen-devel@lists.xen.org,
	Ian.Campbell@citrix.com, JBeulich@suse.com,
	stefano.stabellini@eu.citrix.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372412262.3301.251.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 28 Jun 2013 02:37:42 -0700

> [PATCH] neighbour: fix a race in neigh_destroy()
> 
> There is a race in neighbour code, because neigh_destroy() uses
> skb_queue_purge(&neigh->arp_queue) without holding neighbour lock,
> while other parts of the code assume neighbour rwlock is what
> protects arp_queue
> 
> Convert all skb_queue_purge() calls to the __skb_queue_purge() variant
> 
> Use __skb_queue_head_init() instead of skb_queue_head_init()
> to make clear we do not use arp_queue.lock
> 
> And hold neigh->lock in neigh_destroy() to close the race.
> 
> Reported-by: Joe Jin <joe.jin@oracle.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
