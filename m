From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] rtnetlink: Fix problem with buffer allocation
Date: Tue, 21 Feb 2012 16:57:50 -0500 (EST)
Message-ID: <20120221.165750.2246668899195223381.davem@davemloft.net>
References: <20120221215127.30280.30853.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32819 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755341Ab2BUV5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 16:57:52 -0500
In-Reply-To: <20120221215127.30280.30853.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>
Date: Tue, 21 Feb 2012 13:51:28 -0800

> Implement a new netlink attribute type IFLA_EXT_MASK.  The mask
> is a 32 bit value that can be used to indicate to the kernel that
> certain extended ifinfo values are requested by the user application.
> At this time the only mask value defined is RTEXT_FILTER_VF to
> indicate that the user wants the ifinfo dump to send information
> about the VFs belonging to the interface.
> 
> This patch fixes a bug in which certain applications do not have
> large enough buffers to accommodate the extra information returned
> by the kernel with large numbers of SR-IOV virtual functions.
> Those applications will not send the new netlink attribute with
> the interface info dump request netlink messages so they will
> not get unexpectedly large request buffers returned by the kernel.
> 
> Modifies the rtnl_calcit function to traverse the list of net
> devices and compute the minimum buffer size that can hold the
> info dumps of all matching devices based upon the filter passed
> in via the new netlink attribute filter mask.  If no filter
> mask is sent then the buffer allocation defaults to NLMSG_GOODSIZE.
> 
> With this change it is possible to add yet to be defined netlink
> attributes to the dump request which should make it fairly extensible
> in the future.
> 
> CC: stable@vger.kernel.org
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>

Applied, with the minor change suggested by Eric in that we can
use the non-RCU list traversal in the calcit function because
we hold the RTNL always when this is invoked.

Thanks!
