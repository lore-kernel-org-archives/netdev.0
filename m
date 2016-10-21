From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net v2] ipv6: fix a potential deadlock in
 do_ipv6_setsockopt()
Date: Fri, 21 Oct 2016 11:29:16 -0400 (EDT)
Message-ID: <20161021.112916.1504671090390906970.davem@davemloft.net>
References: <1476945312-15572-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        sploving1@gmail.com, marcelo.leitner@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56258 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755768AbcJUP3S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 11:29:18 -0400
In-Reply-To: <1476945312-15572-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 19 Oct 2016 23:35:12 -0700

> Baozeng reported this deadlock case:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock([  165.136033] sk_lock-AF_INET6);
>                                lock([  165.136033] rtnl_mutex);
>                                lock([  165.136033] sk_lock-AF_INET6);
>   lock([  165.136033] rtnl_mutex);
> 
> Similar to commit 87e9f0315952
> ("ipv4: fix a potential deadlock in mcast getsockopt() path")
> this is due to we still have a case, ipv6_sock_mc_close(),
> where we acquire sk_lock before rtnl_lock. Close this deadlock
> with the similar solution, that is always acquire rtnl lock first.
> 
> Fixes: baf606d9c9b1 ("ipv4,ipv6: grab rtnl before locking the socket")
> Reported-by: Baozeng Ding <sploving1@gmail.com>
> Tested-by: Baozeng Ding <sploving1@gmail.com>
> Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
