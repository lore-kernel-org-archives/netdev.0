From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net v3] ipv6: reorder ip6_route_dev_notifier after
 ipv6_dev_notf
Date: Mon, 08 May 2017 17:32:05 -0400 (EDT)
Message-ID: <20170508.173205.572226655248101420.davem@davemloft.net>
References: <1494263533-22325-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com, dsahern@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41414 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750835AbdEHVcI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 17:32:08 -0400
In-Reply-To: <1494263533-22325-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon,  8 May 2017 10:12:13 -0700

> For each netns (except init_net), we initialize its null entry
> in 3 places:
> 
> 1) The template itself, as we use kmemdup()
> 2) Code around dst_init_metrics() in ip6_route_net_init()
> 3) ip6_route_dev_notify(), which is supposed to initialize it after
>    loopback registers
> 
> Unfortunately the last one still happens in a wrong order because
> we expect to initialize net->ipv6.ip6_null_entry->rt6i_idev to
> net->loopback_dev's idev, thus we have to do that after we add
> idev to loopback. However, this notifier has priority == 0 same as
> ipv6_dev_notf, and ipv6_dev_notf is registered after
> ip6_route_dev_notifier so it is called actually after
> ip6_route_dev_notifier. This is similar to commit 2f460933f58e
> ("ipv6: initialize route null entry in addrconf_init()") which
> fixes init_net.
> 
> Fix it by picking a smaller priority for ip6_route_dev_notifier.
> Also, we have to release the refcnt accordingly when unregistering
> loopback_dev because device exit functions are called before subsys
> exit functions.
> 
> Acked-by: David Ahern <dsahern@gmail.com>
> Tested-by: David Ahern <dsahern@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
