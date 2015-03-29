From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netns: don't clear nsid too early on removal
Date: Sun, 29 Mar 2015 12:59:43 -0700 (PDT)
Message-ID: <20150329.125943.122692803288245512.davem@davemloft.net>
References: <1427388998-4393-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59380 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411AbbC2Tu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 15:50:59 -0400
In-Reply-To: <1427388998-4393-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 26 Mar 2015 17:56:38 +0100

> With the current code, ids are removed too early.
> Suppose you have an ipip interface that stands in the netns foo and its link
> part in the netns bar (so the netns bar has an nsid into the netns foo).
> Now, you remove the netns bar:
>  - the bar nsid into the netns foo is removed
>  - the netns exit method of ipip is called, thus our ipip iface is removed:
>    => a netlink message is sent in the netns foo to advertise this deletion
>    => this netlink message requests an nsid for bar, thus a new nsid is
>       allocated for bar and never removed.
> 
> We must remove nsids when we are sure that nobody will refer to netns currently
> cleaned.
> 
> Fixes: 0c7aecd4bde4 ("netns: add rtnl cmd to add and get peer netns ids")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks.
