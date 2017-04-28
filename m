From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: adjust skb->truesize in ___pskb_trim()
Date: Fri, 28 Apr 2017 16:07:37 -0400 (EDT)
Message-ID: <20170428.160737.2032130324003409164.davem@davemloft.net>
References: <1493222866.6453.75.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58656 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1035426AbdD1UHj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 16:07:39 -0400
In-Reply-To: <1493222866.6453.75.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Apr 2017 09:07:46 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Andrey found a way to trigger the WARN_ON_ONCE(delta < len) in
> skb_try_coalesce() using syzkaller and a filter attached to a TCP
> socket.
> 
> As we did recently in commit 158f323b9868 ("net: adjust skb->truesize in
> pskb_expand_head()") we can adjust skb->truesize from ___pskb_trim(),
> via a call to skb_condense().
> 
> If all frags were freed, then skb->truesize can be recomputed.
> 
> This call can be done if skb is not yet owned, or destructor is
> sock_edemux().
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>

Also applied, thanks Eric.
