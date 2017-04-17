From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv4: fix a deadlock in ip_ra_control
Date: Mon, 17 Apr 2017 12:47:22 -0400 (EDT)
Message-ID: <20170417.124722.952972773056039579.davem@davemloft.net>
References: <1492025533-23084-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, andreyknvl@google.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55162 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755042AbdDQQrX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 12:47:23 -0400
In-Reply-To: <1492025533-23084-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 12 Apr 2017 12:32:13 -0700

> Similar to commit 87e9f0315952
> ("ipv4: fix a potential deadlock in mcast getsockopt() path"),
> there is a deadlock scenario for IP_ROUTER_ALERT too:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock(rtnl_mutex);
>                                lock(sk_lock-AF_INET);
>                                lock(rtnl_mutex);
>   lock(sk_lock-AF_INET);
> 
> Fix this by always locking RTNL first on all setsockopt() paths.
> 
> Note, after this patch ip_ra_lock is no longer needed either.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
