From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Fri, 04 Mar 2016 17:50:32 -0500 (EST)
Message-ID: <20160304.175032.1728003538386465719.davem@davemloft.net>
References: <20160304213920.GJ4184@uranus.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com, eric.dumazet@gmail.com
To: gorcunov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759497AbcCDWuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 17:50:37 -0500
In-Reply-To: <20160304213920.GJ4184@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Sat, 5 Mar 2016 00:39:20 +0300

> Currenlty all the kernels (including vanilla) free ifa
> list under rtln_lock() taken which takes a huge time
> to release all entries when we stop the container.
> Moreover it's allowed to create unlimited number
> of addresses from inside of net-namespace if
> CAP-NET_ADMIN granted (which is common for containers).
> 
> Lets introduce per-net limit (4096 by default)
> of addresses, which can be tuned up via sysfs
> entry /proc/sys/net/ipv4/ifa_limit.
> 
> Reported-by: Solar Designer <solar@openwall.com>
> Signed-off-by: Cyrill Gorcunov <gorcunov@virtuozzo.com>

Arbitrary limits are... arbitrary.

If the freeing loop is the issue, splice the list at teardown and
process that list asynchronously via a workqueue or similar.

Thanks.
