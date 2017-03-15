From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: properly release sk_frag.page
Date: Wed, 15 Mar 2017 15:38:11 -0700 (PDT)
Message-ID: <20170315.153811.1553669986617106938.davem@davemloft.net>
References: <1489609288.28631.161.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55486 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753043AbdCOWos (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 18:44:48 -0400
In-Reply-To: <1489609288.28631.161.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 15 Mar 2017 13:21:28 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> I mistakenly added the code to release sk->sk_frag in
> sk_common_release() instead of sk_destruct()
> 
> TCP sockets using sk->sk_allocation == GFP_ATOMIC do no call
> sk_common_release() at close time, thus leaking one (order-3) page.
> 
> iSCSI is using such sockets.
> 
> Fixes: 5640f7685831 ("net: use a per task frag allocator")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
