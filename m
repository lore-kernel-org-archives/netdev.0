From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPoIB: Stop lying about hard_header_len and use
 skb->cb to stash LL addresses
Date: Wed, 08 Feb 2012 15:50:18 -0500 (EST)
Message-ID: <20120208.155018.1656553782073149044.davem@davemloft.net>
References: <CAG4TOxP2iEgT64L8vAR6P139U-HyHSxU8gdWw+cLsDwWSGkrwA@mail.gmail.com>
	<1328662281-16256-1-git-send-email-roland@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ogerlitz@mellanox.com,
	sean.hefty@intel.com, herbert@gondor.hengli.com.au,
	linux-rdma@vger.kernel.org, shlomop@mellanox.com,
	netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47556 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752188Ab2BHUud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 15:50:33 -0500
In-Reply-To: <1328662281-16256-1-git-send-email-roland@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@kernel.org>
Date: Tue,  7 Feb 2012 16:51:21 -0800

> From: Roland Dreier <roland@purestorage.com>
> 
> Commit a0417fa3a18a ("net: Make qdisc_skb_cb upper size bound
> explicit.") made it possible for a netdev driver to use skb->cb
> between its header_ops.create method and its .ndo_start_xmit
> method.  Use this in ipoib_hard_header() to stash away the LL address
> (GID + QPN), instead of the "ipoib_pseudoheader" hack.  This allows
> IPoIB to stop lying about its hard_header_len, which will let us fix
> the L2 check for GRO.
> 
> Signed-off-by: Roland Dreier <roland@purestorage.com>
> ---
> OK, this works for me.  Definitely looks cleaner and also looks
> obvious enough that it's probably even correct.

I'll toss this, and Eric's updated patch into net-next, thanks!
