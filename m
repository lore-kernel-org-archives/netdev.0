From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: reduce skb overhead in selected places
Date: Wed, 25 Jan 2017 10:38:52 -0800
Message-ID: <1485369532.5145.50.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485298656.16328.355.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170125.131717.489451306351372553.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35272 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752426AbdAYSjD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 13:39:03 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so20366815pge.2
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 10:39:03 -0800 (PST)
In-Reply-To: <20170125.131717.489451306351372553.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-25 at 13:17 -0500, David Miller wrote:

> Applied, thanks Eric.

Thanks David.

It looks IPv6 potential big network headers are also a threat :

Various pskb_may_pull() to pull headers might reallocate skb->head,
but skb->truesize is not updated in __pskb_pull_tail()

We probably need to update skb->truesize, but it is tricky as the prior
skb->truesize value might have been used for memory accounting when skb
was stored in some queue.

Do you think we could change __pskb_pull_tail() right away and fix the
few places that would break, or should we add various helpers with extra
parameters to take a safe route ?
