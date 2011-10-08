From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 02/11] igb: Use node specific allocations for the
 q_vectors and rings
Date: Sat, 08 Oct 2011 15:51:58 -0400 (EDT)
Message-ID: <20111008.155158.566839176815794249.davem@davemloft.net>
References: <1318056461-19562-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1318056461-19562-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753812Ab1JHTwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 15:52:08 -0400
In-Reply-To: <1318056461-19562-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri,  7 Oct 2011 23:47:32 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change is meant to update the ring and vector allocations so that they
> are per node instead of allocating everything on the node that
> ifconfig/modprobe is called on.  By doing this we can cut down
> significantly on cross node traffic.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

adapter->node seems superfluous.

It's always "-1" when we enter the allocation functions, and we
always restore it to it's original value upon exit from such
functions.

Just get rid of it and use a local variable in these functions
to keep track of the current allocation node.

Also, what ensures that MSI-X interrupts are targetted to a cpu
on the the node where you've made these allocations?  I was
pretty sure Ben Hutchings added infrastructure that's usable
to ensure this, but I can't see where you're using it.
