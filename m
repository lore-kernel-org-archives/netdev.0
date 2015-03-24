From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: allow to delete a whole device group
Date: Tue, 24 Mar 2015 13:11:05 -0400 (EDT)
Message-ID: <20150324.131105.1048577882668644719.davem@davemloft.net>
References: <1427155455-8257-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37690 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932185AbbCXRLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 13:11:07 -0400
In-Reply-To: <1427155455-8257-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 23 Mar 2015 17:04:15 -0700

> +	for_each_netdev_safe(net, dev, aux) {
> +		if (dev->group == group) {
> +			const struct rtnl_link_ops *ops;
> +
> +			found = true;
> +			ops = dev->rtnl_link_ops;
> +			if (!ops || !ops->dellink)
> +				return -EOPNOTSUPP;
> +			ops->dellink(dev, &list_kill);
> +		}

These semantics are terrible.

A netlink request should always strive (no, I'll say it _must_) either
fully perform the requested operation for all relevant objects, or
have no side effects and return an error.

If need be you must completely unwind all partial changes before
returning that error, or alternatively defer commiting the
changes until you can guarantee that all of them can be performed.
