From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for
 neigh_timer_handler()
Date: Wed, 04 Dec 2013 01:36:38 -0500 (EST)
Message-ID: <20131204.013638.2211412920346095879.davem@davemloft.net>
References: <529EA9CF.2090008@huawei.com>
	<20131203.232122.852236751455974887.davem@davemloft.net>
	<529EC95A.5080908@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, yoshfuji@linux-ipv6.org, joe@perches.com,
	vfalico@redhat.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046Ab3LDGgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 01:36:43 -0500
In-Reply-To: <529EC95A.5080908@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Wed, 4 Dec 2013 14:19:06 +0800

> Yes, you are right, but when the timer is running and prior to get
> the neigh->lock, the refcnt could be dec to 0, you could not stop it
> by existing mechanism.
> 
> the refcnt of neighbour could only be inc by these actions:
> 
> 1.create neighbour, the refcnt will be set to 1.
> 2.add timer, the refcnt++.
> 3.neigh_lookup, if found the neigh, refcnt++.

The refcnt cannot dec to 0 if the timer is running, that's why
the last action of the timer handler is neigh_release().

The timer handler always holds a reference to the neighbour entry for
which it is running, that is why it must always release it.

If it can dec to 0, then this neigh_release() call in the timer
handler is illegal.  But it is not.
