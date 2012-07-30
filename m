From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] ipv6: fix incorrect route 'expires' value passed to
 userspace
Date: Sun, 29 Jul 2012 23:20:03 -0700 (PDT)
Message-ID: <20120729.232003.294943620790250104.davem@davemloft.net>
References: <1343199114.2626.11088.camel@edumazet-glaptop>
	<1343613690-3236-1-git-send-email-lw@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385Ab2G3GUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 02:20:04 -0400
In-Reply-To: <1343613690-3236-1-git-send-email-lw@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Mon, 30 Jul 2012 10:01:30 +0800

> When userspace use RTM_GETROUTE to dump route table, with an already
> expired route entry, we always got an 'expires' value(2147157)
> calculated base on INT_MAX.
> 
> The reason of this problem is in the following satement:
> 	rt->dst.expires - jiffies < INT_MAX
> gcc promoted the type of both sides of '<' to unsigned long, thus
> a small negative value would be considered greater than INT_MAX.
> 
> With the help of Eric Dumazet, do the out of bound checks in
> rtnl_put_cacheinfo(), _after_ conversion to clock_t.
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>

Applied.
