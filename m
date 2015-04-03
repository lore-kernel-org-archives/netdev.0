From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] netns: don't allocate an id for dead netns
Date: Fri, 03 Apr 2015 12:36:50 -0400 (EDT)
Message-ID: <20150403.123650.1819000124764491725.davem@davemloft.net>
References: <551E63B9.9050208@6wind.com>
	<1428055357-15289-1-git-send-email-nicolas.dichtel@6wind.com>
	<1428055357-15289-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617AbbDCQgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 12:36:52 -0400
In-Reply-To: <1428055357-15289-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri,  3 Apr 2015 12:02:37 +0200

> First, let's explain the problem.
> Suppose you have an ipip interface that stands in the netns foo and its link
> part in the netns bar (so the netns bar has an nsid into the netns foo).
> Now, you remove the netns bar:
>  - the bar nsid into the netns foo is removed
>  - the netns exit method of ipip is called, thus our ipip iface is removed:
>    => a netlink message is built in the netns foo to advertise this deletion
>    => this netlink message requests an nsid for bar, thus a new nsid is
>       allocated for bar and never removed.
> 
> This patch adds a check in peernet2id() so that an id cannot be allocated for
> a netns which is currently destroyed.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
