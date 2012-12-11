From: David Miller <davem@davemloft.net>
Subject: Re: netdevice wanrouter: Convert directly reference of netdev->priv
Date: Tue, 11 Dec 2012 13:43:10 -0500 (EST)
Message-ID: <20121211.134310.1757064654502486858.davem@davemloft.net>
References: <20121203090405.GA12089@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754417Ab2LKSnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 13:43:12 -0500
In-Reply-To: <20121203090405.GA12089@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 3 Dec 2012 12:04:05 +0300

> I suspect we should just revert the patch?

That is absolutely something we cannot do.

netdev->priv no longer exists, first of all.

And the whole point of this change was to allow us to
remove any and all references to netdev->priv, exactly
so that we could remove it altogether.

If you look at the commit in question, the idea is to
allocate the netdev in the ->new_if() callback.

And that's in fact what happens.

What's missing at the top level is something like:

	dev = wandev->dev;

And perhaps removing the 'dev' argument to the ->new_if()
method since it obviously is always NULL and never actually
used.

Thanks.
