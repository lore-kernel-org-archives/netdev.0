From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: fix undefined __ipv6_sock_mc_join
 compile error
Date: Mon, 09 Mar 2015 22:37:28 -0400 (EDT)
Message-ID: <20150309.223728.1949540375176208819.davem@davemloft.net>
References: <1425953333-31403-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, fengguang.wu@intel.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	kbuild-all@01.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122AbbCJChc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 22:37:32 -0400
In-Reply-To: <1425953333-31403-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Tue, 10 Mar 2015 10:08:52 +0800

> When CONFIG_IPV6 option is disabled, below compile error appears while
> building TIPC module:
> 
> ERROR: "__ipv6_sock_mc_join" [net/tipc/tipc.ko] undefined!
> make[1]: *** [__modpost] Error 1
> make: *** [net/tipc/tipc.ko] Error 1
> 
> This is because we don't check whether or not the CONFIG_IPV6 is
> enabled when calling __ipv6_sock_mc_join().
> 
> Fixes: d0f91938bede ("tipc: add ip/udp media type")
> Reported-by: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Kbuild test robot <kbuild-all@01.org>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Unfortunately, that's not sufficient.

You also need Kconfig guards to prevent building TIPC=y,
TIPC_MEDIA_UDP=y, and IPV6=m which will not work.

Look at other users of ipv6_*() interface, such as L2TP.
You need a dependency like (IPV6 || IPV6=n).
