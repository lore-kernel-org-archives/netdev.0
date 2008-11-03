From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] net/9p: limit RDMA to INET
Date: Mon, 03 Nov 2008 12:52:50 -0800
Message-ID: <aday700v8f1.fsf@cisco.com>
References: <20081103111731.d12dbb84.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org,
	sfr <sfr@canb.auug.org.au>, rolandd@cisco.com, ericvh@gmail.com,
	akpm <akpm@linux-foundation.org>, davem@davemloft.net,
	netdev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:14715 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756195AbYKCUwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 15:52:54 -0500
In-Reply-To: <20081103111731.d12dbb84.randy.dunlap@oracle.com> (Randy Dunlap's
	message of "Mon, 3 Nov 2008 11:17:31 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > Make 9p's RDMA option depend on INET since it uses Infiniband rdma_*
 > functions and that code depends on INET.  Otherwise 9p can try to
 > use symbols which don't exist.
 > 
 > ERROR: "rdma_destroy_id" [net/9p/9pnet_rdma.ko] undefined!

Good catch.

 >  config NET_9P_RDMA
 > -	depends on NET_9P && INFINIBAND && EXPERIMENTAL
 > +	depends on INET && INFINIBAND && EXPERIMENTAL

I wonder if there's a way to make this depend on INFINIBAND_ADDR_TRANS
instead of INET, since that's the real dependency to get the rdma_*
symbols.  However INFINIBAND_ADDR_TRANS is a bool that gets set to y iff
INET and INFINIBAND are set, so it's not trivial to make a tristate
depend on it.

Maybe this patch is fine as it is, since the Kconfig dependencies are
unlikely to change anyway...

 - R.
