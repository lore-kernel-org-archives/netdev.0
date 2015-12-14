From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: Flush local routes when device changes vrf
 association
Date: Sun, 13 Dec 2015 23:59:48 -0500 (EST)
Message-ID: <20151213.235948.2125623235400954469.davem@davemloft.net>
References: <1449771924-21775-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ja@ssi.bg
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346AbbLNE7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2015 23:59:50 -0500
In-Reply-To: <1449771924-21775-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 10 Dec 2015 10:25:24 -0800

> The VRF driver cycles netdevs when an interface is enslaved or released:
> the down event is used to flush neighbor and route tables and the up
> event (if the interface was already up) effectively moves local and
> connected routes to the proper table.
> 
> As of 4f823defdd5b the local route is left hanging around after a link
> down, so when a netdev is moved from one VRF to another (or released
> from a VRF altogether) local routes are left in the wrong table.
> 
> Fix by handling the NETDEV_CHANGEUPPER event. When the upper dev is
> an L3mdev then call fib_disable_ip to flush all routes, local ones
> to.
> 
> Fixes: 4f823defdd5b ("ipv4: fix to not remove local route on link down")
> Cc: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks.
