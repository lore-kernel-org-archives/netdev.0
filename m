From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipmr: restrict mroute "queue full"
 warning to related error values
Date: Fri, 23 Jun 2017 13:39:47 -0400 (EDT)
Message-ID: <20170623.133947.433422648753848462.davem@davemloft.net>
References: <20170621175811.16940-1-julien@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: julien@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34418 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754625AbdFWRjt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 13:39:49 -0400
In-Reply-To: <20170621175811.16940-1-julien@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Gomes <julien@arista.com>
Date: Wed, 21 Jun 2017 10:58:10 -0700

> When sending a cache report on mroute_sk, mroute will emit a
> "pending queue full" warning for every error value returned by
> sock_queue_rcv_skb().
> This warning can be misleading, for example on the EPERM error value
> that sk_filter() can return.
> 
> Restricting this warning to only ENOMEM or ENOBUFS seems more
> appropriate.
> 
> Signed-off-by: Julien Gomes <julien@arista.com>

Incorrect, no other error codes are possible.

We never attach a socket filter to these kernel internal sockets,
therefore sk_filter() is not even applicable in this analysis.

Therefore, -ENOBUFS and -ENOMEM are the only errors we can ever see
returned from sock_queue_rcv_skb().

This goes for your second patch as well.
