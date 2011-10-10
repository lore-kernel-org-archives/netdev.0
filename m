From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 02/11] igb: Use node specific allocations for the q_vectors
 and rings
Date: Mon, 10 Oct 2011 09:25:05 -0700
Message-ID: <4E931C61.7040204@intel.com>
References: <1318056461-19562-1-git-send-email-jeffrey.t.kirsher@intel.com>	<1318056461-19562-3-git-send-email-jeffrey.t.kirsher@intel.com> <m21uum2g28.fsf@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16156 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751924Ab1JJQZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 12:25:00 -0400
In-Reply-To: <m21uum2g28.fsf@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2011 11:08 AM, Andi Kleen wrote:
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> writes:
>>  
>>  	for (i = 0; i < adapter->num_tx_queues; i++) {
>> -		ring = kzalloc(sizeof(struct igb_ring), GFP_KERNEL);
>> +		if (orig_node == -1) {
>> +			int cur_node = next_online_node(adapter->node);
>> +			if (cur_node == MAX_NUMNODES)
>> +				cur_node = first_online_node;
> 
> RR seems quite arbitrary. Who guarantees those nodes have any
> relationship with the CPUs submitting on those queues? Or the node
> the device is on.
> 
> Anyways if it's a good idea probably need to add a
> dma_alloc_coherent_node() too
> 
> -Andi
> 

The RR configuration is somewhat arbitrary.  However it is still better
than dumping everyting on a single node, and it works with the
configuration when the rings numbers line up with the CPU numbers since
normally the CPUs are RR on the nodes.  From what I have seen it does
work quite well and it prevents almost all cross-node memory accesses
when running a routing workload.

I was thinking along the same lines for dma_alloc_coherent_node as well.
 I've been meaning to get to it but I just haven't had the time.  I'm
intentionally holding off on the ixgbe version of these patches until I
get the time to write up such a function.  At which time I was going to
write up a patch to convert igb over to it.

Thanks,

Alex
