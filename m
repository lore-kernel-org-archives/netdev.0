From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [net-next 02/11] igb: Use node specific allocations for the q_vectors and rings
Date: Sun, 09 Oct 2011 11:08:47 -0700
Message-ID: <m21uum2g28.fsf@firstfloor.org>
References: <1318056461-19562-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1318056461-19562-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:49376 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752017Ab1JISIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Oct 2011 14:08:49 -0400
In-Reply-To: <1318056461-19562-3-git-send-email-jeffrey.t.kirsher@intel.com>
	(Jeff Kirsher's message of "Fri, 7 Oct 2011 23:47:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher <jeffrey.t.kirsher@intel.com> writes:
>  
>  	for (i = 0; i < adapter->num_tx_queues; i++) {
> -		ring = kzalloc(sizeof(struct igb_ring), GFP_KERNEL);
> +		if (orig_node == -1) {
> +			int cur_node = next_online_node(adapter->node);
> +			if (cur_node == MAX_NUMNODES)
> +				cur_node = first_online_node;

RR seems quite arbitrary. Who guarantees those nodes have any
relationship with the CPUs submitting on those queues? Or the node
the device is on.

Anyways if it's a good idea probably need to add a
dma_alloc_coherent_node() too

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
