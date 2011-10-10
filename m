From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [net-next 02/11] igb: Use node specific allocations for the q_vectors and rings
Date: Mon, 10 Oct 2011 18:32:28 +0200
Message-ID: <20111010163228.GA14482@one.firstfloor.org>
References: <1318056461-19562-1-git-send-email-jeffrey.t.kirsher@intel.com> <1318056461-19562-3-git-send-email-jeffrey.t.kirsher@intel.com> <m21uum2g28.fsf@firstfloor.org> <4E931C61.7040204@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:34320 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912Ab1JJQcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 12:32:32 -0400
Content-Disposition: inline
In-Reply-To: <4E931C61.7040204@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The RR configuration is somewhat arbitrary.  However it is still better
> than dumping everyting on a single node, and it works with the
> configuration when the rings numbers line up with the CPU numbers since
> normally the CPUs are RR on the nodes.  From what I have seen it does
> work quite well and it prevents almost all cross-node memory accesses
> when running a routing workload.

Ok so it's optimized for one specific workload. I'm sure you'll
find some other workload where it doesn't work out.

I suppose it's hard to get right in the general case, but best
would be if ethtool had a nice and easy interface to set it at least.

However one disadvantage of that patch over the existing state of the
art (numactl modprobe ...) is that there's no way to override the placement
now. So if you do the forced RR I think you need the ethtool part too,
or at least some parameter to turn it off.

-Andi
