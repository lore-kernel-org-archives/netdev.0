From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] tcp: tcp_get_info() locking changes
Date: Wed, 09 Nov 2016 13:03:19 -0500 (EST)
Message-ID: <20161109.130319.505221196913812307.davem@davemloft.net>
References: <1478285672-3195-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
        soheil@google.com, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37890 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754641AbcKISDV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:03:21 -0500
In-Reply-To: <1478285672-3195-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Fri,  4 Nov 2016 11:54:30 -0700

> This short series prepares tcp_get_info() for more detailed infos.
> 
> In order to not slow down fast path, our goal is to use the normal
> socket spinlock instead of custom synchronization.
> 
> All we need to ensure is that tcp_get_info() is not called with
> ehash lock, which might dead lock, since packet processing would acquire
> the spinlocks in reverse way.

Looks really nice, series applied, thanks Eric.

BTW, can we possibly use the netlink NOP trick to align the netlink
attribute data here and avoid these unaligned accesses?

Thanks again.
