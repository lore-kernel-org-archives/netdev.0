From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] net: speedup netns create/delete time
Date: Tue, 19 Sep 2017 16:02:44 -0700 (PDT)
Message-ID: <20170919.160244.1149642515939268316.davem@davemloft.net>
References: <20170918190733.26272-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
        eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49936 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751575AbdISXCo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 19:02:44 -0400
In-Reply-To: <20170918190733.26272-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon, 18 Sep 2017 12:07:26 -0700

> When rate of netns creation/deletion is high enough,
> we observe softlockups in cleanup_net() caused by huge list
> of netns and way too many rcu_barrier() calls.
> 
> This patch series does some optimizations in kobject,
> and add batching to tunnels so that netns dismantles are
> less costly.
> 
> IPv6 addrlabels also get a per netns list, and tcp_metrics
> also benefit from batch flushing.
> 
> This gives me one order of magnitude gain.
> (~50 ms -> ~5 ms for one netns create/delete pair)

I like it.

Please address the feedback about using skb_put_data() and
resubmit.

Thanks.
