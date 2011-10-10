From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 02/11] igb: Use node specific allocations for the q_vectors
 and rings
Date: Mon, 10 Oct 2011 10:02:07 -0700
Message-ID: <4E93250F.9090000@intel.com>
References: <1318056461-19562-1-git-send-email-jeffrey.t.kirsher@intel.com> <1318056461-19562-3-git-send-email-jeffrey.t.kirsher@intel.com> <m21uum2g28.fsf@firstfloor.org> <4E931C61.7040204@intel.com> <20111010163228.GA14482@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:64915 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752456Ab1JJRB5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 13:01:57 -0400
In-Reply-To: <20111010163228.GA14482@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2011 09:32 AM, Andi Kleen wrote:
>> The RR configuration is somewhat arbitrary.  However it is still better
>> than dumping everyting on a single node, and it works with the
>> configuration when the rings numbers line up with the CPU numbers since
>> normally the CPUs are RR on the nodes.  From what I have seen it does
>> work quite well and it prevents almost all cross-node memory accesses
>> when running a routing workload.
> 
> Ok so it's optimized for one specific workload. I'm sure you'll
> find some other workload where it doesn't work out.

It isn't that I optimized it for one specific workload.  I was just
citing that specific workload as one of the ones seeing the advantage.

> I suppose it's hard to get right in the general case, but best
> would be if ethtool had a nice and easy interface to set it at least.

The general case is never right for this it seems like.  At least in
this case it becomes much easier to line up the memory and interrupts so
that they are all affinitized to the same core.  From there RPS/RFS can
typically be used to spread out the work more if necessary.

> However one disadvantage of that patch over the existing state of the
> art (numactl modprobe ...) is that there's no way to override the placement
> now. So if you do the forced RR I think you need the ethtool part too,
> or at least some parameter to turn it off.
> 
> -Andi

The counter argument to that though is that the approach you mention
always limits you to one node.  At least with this approach we are
spread out over multiple nodes so that we can make full use of the
memory bandwidth on the system.

Thanks,

Alex
