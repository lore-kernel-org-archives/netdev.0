From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: fix a slab object leak
Date: Tue, 31 Mar 2015 23:13:09 -0400 (EDT)
Message-ID: <20150331.231309.610369858855748160.davem@davemloft.net>
References: <1427852570-25210-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53068 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271AbbDADNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 23:13:11 -0400
In-Reply-To: <1427852570-25210-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 1 Apr 2015 09:42:50 +0800

> When remove TIPC module, there is a warning to remind us that a slab
> object is leaked like:
> 
> root@localhost:~# rmmod tipc
> [   19.056226] =============================================================================
> [   19.057549] BUG TIPC (Not tainted): Objects remaining in TIPC on kmem_cache_close()
> [   19.058736] -----------------------------------------------------------------------------
> [   19.058736]
> [   19.060287] INFO: Slab 0xffffea0000519a00 objects=23 used=1 fp=0xffff880014668b00 flags=0x100000000004080
> [   19.061915] INFO: Object 0xffff880014668000 @offset=0
> [   19.062717] kmem_cache_destroy TIPC: Slab cache still has objects
> 
> This is because the listening socket of TIPC topology server is not
> closed before TIPC proto handler is unregistered with proto_unregister().
> However, as the socket is closed in tipc_exit_net() which is called by
> unregister_pernet_subsys() during unregistering TIPC namespace operation,
> the warning can be eliminated if calling unregister_pernet_subsys() is
> moved before calling proto_unregister().
> 
> Fixes: e05b31f4bf89 ("tipc: make tipc socket support net namespace")
> Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

This bug exists in 'net', so that's where I'm applying it.

Can you please target your patches properly, I shouldn't be
doing this kind of work for you.
