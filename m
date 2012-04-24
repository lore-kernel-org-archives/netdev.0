From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/neigh: move neigh cleanup routine to
 neigh_destroy
Date: Tue, 24 Apr 2012 00:53:09 -0400 (EDT)
Message-ID: <20120424.005309.2292973770816115829.davem@davemloft.net>
References: <1335195282-28738-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shlomop@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35449 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287Ab2DXExP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 00:53:15 -0400
In-Reply-To: <1335195282-28738-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Mon, 23 Apr 2012 18:34:42 +0300

> From: Shlomo Pongratz <shlomop@mellanox.com>
> 
> Move call the neigh_cleanup call to be done from neigh_destroy, this
> ensures the cleanup callback is invoked only when the neighbour reference
> count becomes zero (e.g in the same manner as ndo_neigh_destory).
> 
> Note that with this change neigh_destroy will truly revert the action of
> neigh_create, as neigh_release which calls neigh_destroy is called directly
> from various code paths, and thus neigh->parms->neigh_cleanup is not called
> for these code paths.
> 
> Also, with commit 7d26bb103 "bonding: emit event when bonding changes MAC" that
> triggers netdev address change event, a race was introduced since neigh cleanup
> can be called when there's reference on the neighbour.
> 
> Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

With IPOIB, the neigh_cleanup purges references to the neigh when it
liberates the SKBs in the neigh resolution TX backlog during
ipoib_neigh_free().

Therefore, with your change, IPOIB neighs will never be destroyed if
they have any SKBs in their neigh resolution queues.

I'm not applying this, it's buggy.
