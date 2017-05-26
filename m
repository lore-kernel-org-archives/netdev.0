From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: add reference counting to metrics
Date: Fri, 26 May 2017 14:58:24 -0400 (EDT)
Message-ID: <20170526.145824.2020171973211229273.davem@davemloft.net>
References: <CAM_iQpUfLmN3yWsCfpx4ZTptBnuYFNuY5CjBKdwoDpvH5K8P=w@mail.gmail.com>
        <1495665921.6465.95.camel@edumazet-glaptop3.roam.corp.google.com>
        <1495747655.6465.113.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, andreyknvl@google.com, ja@ssi.bg,
        xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43606 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754123AbdEZS6b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 14:58:31 -0400
In-Reply-To: <1495747655.6465.113.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 25 May 2017 14:27:35 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Andrey Konovalov reported crashes in ipv4_mtu()
> 
> I could reproduce the issue with KASAN kernels, between
> 10.246.7.151 and 10.246.7.152 :
> 
> 1) 20 concurrent netperf -t TCP_RR -H 10.246.7.152 -l 1000 &
> 
> 2) At the same time run following loop :
> while :
> do
>  ip ro add 10.246.7.152 dev eth0 src 10.246.7.151 mtu 1500
>  ip ro del 10.246.7.152 dev eth0 src 10.246.7.151 mtu 1500
> done
> 
> 
> Cong Wang attempted to add back rt->fi in commit
> 82486aa6f1b9 ("ipv4: restore rt->fi for reference counting")
> but this proved to add some issues that were complex to solve.
> 
> Instead, I suggested to add a refcount to the metrics themselves,
> being a standalone object (in particular, no reference to other objects)
> 
> I tried to make this patch as small as possible to ease its backport,
> instead of being super clean. Note that we believe that only ipv4 dst
> need to take care of the metric refcount. But if this is wrong,
> this patch adds the basic infrastructure to extend this to other
> families.
> 
> Many thanks to Julian Anastasov for reviewing this patch, and Cong Wang
> for his efforts on this problem.
> 
> Fixes: 2860583fe840 ("ipv4: Kill rt->fi")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>

Applied, thanks everyone for following through on this bug fix.

And sorry for introducing the problem in the first place :)
