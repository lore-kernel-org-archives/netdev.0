From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix out of bound writes in
 __ip6_append_data()
Date: Mon, 22 May 2017 11:48:34 -0400 (EDT)
Message-ID: <20170522.114834.59066499542253617.davem@davemloft.net>
References: <CANn89iJ4GJfrJvdzpMesGkUvYzJfUnMwbyPOzDxZdQDAJbkptg@mail.gmail.com>
        <CAAeHK+xGCjM8oDCZcNXbaZZNqenREi4DUgHM5=Ab7GKrVEmO4Q@mail.gmail.com>
        <1495228668.6465.44.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andreyknvl@google.com, edumazet@google.com, idaifish@gmail.com,
        netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53488 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752864AbdEVPtl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 11:49:41 -0400
In-Reply-To: <1495228668.6465.44.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 May 2017 14:17:48 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Andrey Konovalov and idaifish@gmail.com reported crashes caused by
> one skb shared_info being overwritten from __ip6_append_data()
> 
> Andrey program lead to following state :
> 
> copy -4200 datalen 2000 fraglen 2040 
> maxfraglen 2040 alloclen 2048 transhdrlen 0 offset 0 fraggap 6200
> 
> The skb_copy_and_csum_bits(skb_prev, maxfraglen, data + transhdrlen,
> fraggap, 0); is overwriting skb->head and skb_shared_info
> 
> Since we apparently detect this rare condition too late, move the
> code earlier to even avoid allocating skb and risking crashes.
> 
> Once again, many thanks to Andrey and syzkaller team.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>
> Reported-by: <idaifish@gmail.com>

Looks good, applied and queued up for -stable.

Thanks Eric.
