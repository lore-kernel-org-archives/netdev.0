From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipvlan: fix crash when master is set in
 loopback mode
Date: Mon, 19 Dec 2016 11:11:56 -0500 (EST)
Message-ID: <20161219.111156.1987012114474401231.davem@davemloft.net>
References: <1482087625-30366-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46880 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755441AbcLSQL6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 11:11:58 -0500
In-Reply-To: <1482087625-30366-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Sun, 18 Dec 2016 11:00:25 -0800

> From: Mahesh Bandewar <maheshb@google.com>
> 
> In an IPvlan setup when master is set in loopback mode e.g.
> 
>   ethtool -K eth0 set loopback on
> 
>   where eth0 is master device for IPvlan setup.
> 
> The failure actually happens while processing mulitcast packets
> but that's a result of unconditionally queueing packets without
> ensuring ether-header is part of the linear part of skb.
> 
> This patch forces this check at the reception and drops packets
> which fail this check before queuing them.
...
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> v1->v2: commit log update

Like Eric, I still do not like this change nor the explanation.

Whether in loopback mode or not, your explanation makes no sense at
all.

If the packet comes from the ethernet device, the freakin' ethernet
header is there in the linear SKB area.  No pulling should be needed
whatsoever.

Something creates this bad situation where the ethernet header is not
there, but you have not explained that sufficiently yet.

Thank you.
