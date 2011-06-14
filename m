From: Vasu Dev <vasu.dev@linux.intel.com>
Subject: Re: [net-next 13/13] ixgbe: use per NUMA node lock for FCoE DDP
Date: Mon, 13 Jun 2011 17:02:57 -0700
Message-ID: <1308009777.31900.87.camel@vi2.jf.intel.com>
References: <1307761341-5267-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1307761341-5267-14-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1307769482.2872.62.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46427 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755361Ab1FNAC6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2011 20:02:58 -0400
In-Reply-To: <1307769482.2872.62.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-06-11 at 07:18 +0200, Eric Dumazet wrote:
> > +static void ixgbe_fcoe_lock_init(struct ixgbe_fcoe *fcoe)
> > +{
> > +     int node;
> > +     spinlock_t *node_lock;
> > +
> > +     fcoe->node_lock = kzalloc(sizeof(node_lock) *
> num_possible_nodes(),
> > +                               GFP_KERNEL);
> 
> Hmm...
> 
> 1) Think of what happens if some machine has 3 possible nodes : 0, 2,
> 3
> 
>         -> You should use nr_node_ids instead of num_possible_nodes() 
> 

Just curious won't these both return same values ? Anycase use of
nr_nodes_ids looks better as it is already set. 

> 2) Make sure this block cant have false sharing : Allocate at least a
> full cache line : On a typical 2 node machine, you currently allocate
> 16bytes of memory, and this small block could share a contended cache
> line.

Yeap good point. Thanks

> 
> 
> > +     if (!fcoe->node_lock)

