From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: set fib rule refcount after malloc
Date: Thu, 13 Jul 2017 13:43:35 -0700 (PDT)
Message-ID: <20170713.134335.1544432096954681162.davem@davemloft.net>
References: <1499978200-12331-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, idosch@mellanox.com, jiri@mellanox.com,
        netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51186 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752962AbdGMUng (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 16:43:36 -0400
In-Reply-To: <1499978200-12331-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Thu, 13 Jul 2017 13:36:40 -0700

> The configure callback of fib_rules_ops can change the refcnt of a
> fib rule. For instance, mlxsw takes a refcnt when adding the processing
> of the rule to a work queue. Thus the rule refcnt can not be reset to
> to 1 afterwards. Move the refcnt setting to after the allocation.
> 
> Fixes: 5361e209dd30 ("net: avoid one splat in fib_nl_delrule()")
> Signed-off-by: David Ahern <dsahern@gmail.com>

Can someone keep a scoreboard of how many bugs and arbitrary
unnecessary changes get introduced because of this new refcount_t
business rather than get fixed?

I'd really like to see how that pans out over the long term especially
with all of the backporting pain this facility is going to cause.

Anyways, David I will apply this, thanks.
