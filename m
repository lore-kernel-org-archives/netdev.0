From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [net-next-2.6 PATCH 1/5] ixgbe: Allocate driver resources per NUMA node
Date: Thu, 14 Jan 2010 12:02:06 +0100
Message-ID: <87y6k1dk5t.fsf@basil.nowhere.org>
References: <20100107044741.28605.31414.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:43482 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754941Ab0ANLCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 06:02:08 -0500
In-Reply-To: <20100107044741.28605.31414.stgit@localhost.localdomain> (Jeff Kirsher's message of "Wed, 06 Jan 2010 20:48:26 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher <jeffrey.t.kirsher@intel.com> writes:
>  enum ixbge_state_t {
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index 2ad754c..6895de7 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -3741,7 +3741,8 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
>  	}
>  
>  	for (q_idx = 0; q_idx < num_q_vectors; q_idx++) {
> -		q_vector = kzalloc(sizeof(struct ixgbe_q_vector), GFP_KERNEL);
> +		q_vector = kzalloc_node(sizeof(struct ixgbe_q_vector),
> +		                        GFP_KERNEL, adapter->node);


The problem of doing this is that the node might be full or have
no memory and k*alloc_node will fail then.

So you would need a fallback to be reliable (we probably should have a
generic utility function for this somewhere, but we don't currently)

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
