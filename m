From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: set rt6i_protocol properly in the route when
 it is installed
Date: Thu, 03 Aug 2017 15:10:59 -0700 (PDT)
Message-ID: <20170803.151059.789231468106619997.davem@davemloft.net>
References: <4b7ab03445cf34a630d5185b216de8ab103a20d8.1501740826.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grawity@gmail.com, dsahern@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50096 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751891AbdHCWLA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 18:11:00 -0400
In-Reply-To: <4b7ab03445cf34a630d5185b216de8ab103a20d8.1501740826.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu,  3 Aug 2017 14:13:46 +0800

> After commit c2ed1880fd61 ("net: ipv6: check route protocol when
> deleting routes"), ipv6 route checks rt protocol when trying to
> remove a rt entry.
> 
> It introduced a side effect causing 'ip -6 route flush cache' not
> to work well. When flushing caches with iproute, all route caches
> get dumped from kernel then removed one by one by sending DELROUTE
> requests to kernel for each cache.
> 
> The thing is iproute sends the request with the cache whose proto
> is set with RTPROT_REDIRECT by rt6_fill_node() when kernel dumps
> it. But in kernel the rt_cache protocol is still 0, which causes
> the cache not to be matched and removed.
> 
> So the real reason is rt6i_protocol in the route is not set when
> it is allocated. As David Ahern's suggestion, this patch is to
> set rt6i_protocol properly in the route when it is installed and
> remove the codes setting rtm_protocol according to rt6i_flags in
> rt6_fill_node.
> 
> This is also an improvement to keep rt6i_protocol consistent with
> rtm_protocol.
> 
> Fixes: c2ed1880fd61 ("net: ipv6: check route protocol when deleting routes")
> Reported-by: Jianlin Shi <jishi@redhat.com>
> Suggested-by: David Ahern <dsahern@gmail.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable, thanks.
