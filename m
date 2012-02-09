From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] rtnetlink: Add filter for VF info dump requests
Date: Wed, 08 Feb 2012 20:10:18 -0500 (EST)
Message-ID: <20120208.201018.97784090083485473.davem@davemloft.net>
References: <20120207223346.21320.89370.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49827 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756838Ab2BIBKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 20:10:20 -0500
In-Reply-To: <20120207223346.21320.89370.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>
Date: Tue, 07 Feb 2012 14:33:46 -0800

> Add a 256 bit filter to allow the user to filter which VFs' info will
> get displayed during the dump info request.  This is to fix a bug in
> which a an info dump request on a device with many VFs would overflow
> the recvmsg buffer which is allocated to max(8192, PAGE_SIZE).  A
> complimentary patch to the iproute2 ip tool will allow the user to
> set/clear individual VF filters.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>

This isn't the idea.

I meant we have to add a generic u32 mask attribute to the GETLINK
requests, and it's a mask of "features".  One feature bit would be for
enabling the "VF" part of the dump, another bit would be for the
macvlan source address lists that are being proposed, etc.  Any new
auxiliarry information type we want to add to devide dumps, we have
to add a feature bit for in this mask.

And then you can't just stop there, you have to update all of the
logic related to min_ifinfo_dump_size to take into account the current
request's mask state.

In fact this means you must get rid of the min_info_dump_size global
variable altogether because the size is context dependent upon the
mask configuration of the current dump request.
