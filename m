From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: neighbour: make sure the handler has finished
 before kfree neighbour
Date: Sat, 30 Nov 2013 16:27:33 -0500 (EST)
Message-ID: <20131130.162733.145727596946626316.davem@davemloft.net>
References: <52973704.1030202@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, yoshfuji@linux-ipv6.org, joe@perches.com,
	vfalico@redhat.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940Ab3K3V1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 16:27:35 -0500
In-Reply-To: <52973704.1030202@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Thu, 28 Nov 2013 20:28:52 +0800

> I have met the oops in Suse11 SP2, the kernel is 2.6.32.59-0.7-default:

This doesn't make any sense.

If this actually was the reason, then del_timer() would have returned true,
and thus neigh_del_timer() would have returned "1" and you would have
seen the "Impossible event" log message that neigh_destroy() prints out.

You may think the cause is a pending timer, but the data you've provided
does not support this at all.

And if it isn't happening, your patch removing that warning is wrong.

Furthermore, if this change to use del_timer_sync() is correct, it
probably belongs in neigh_del_timer() because all of it's other callers
expect the timer to not be running and that all references to the object
are stable after such calls.

I'm not applying this, you really need to pursue this bug fix more
cleanly and more thoroughly because it's a non-trivial issue.

Thanks.
