From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] net: do not use rcu in rtnl_dump_ifinfo()
Date: Sun, 01 Mar 2015 00:29:11 -0500 (EST)
Message-ID: <20150301.002911.1745612209348133533.davem@davemloft.net>
References: <54F09A95.8000507@6wind.com>
	<1425056838.5130.27.camel@edumazet-glaptop2.roam.corp.google.com>
	<1425058970.5130.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbbCAF3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 00:29:13 -0500
In-Reply-To: <1425058970.5130.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Feb 2015 09:42:50 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> We did a failed attempt in the past to only use rcu in rtnl dump
> operations (commit e67f88dd12f6 "net: dont hold rtnl mutex during
> netlink dump callbacks")
> 
> Now that dumps are holding RTNL anyway, there is no need to also
> use rcu locking, as it forbids any scheduling ability, like
> GFP_KERNEL allocations that controlling path should use instead
> of GFP_ATOMIC whenever possible.
> 
> This should fix following splat Cong Wang reported :
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: commit 0c7aecd4bde4b7302 ("netns: add rtnl cmd to add and get peer netns ids")
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  v2: As suggested by Daniel, tweak the changelog to be patchwork compliant ;)

Applied, thanks Eric.
