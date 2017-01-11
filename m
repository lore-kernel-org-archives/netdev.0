From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gro: Disable frag0 optimization on IPv6 ext headers
Date: Tue, 10 Jan 2017 21:31:24 -0500 (EST)
Message-ID: <20170110.213124.566361734898965140.davem@davemloft.net>
References: <1484079855.21472.36.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
        slavash@mellanox.com, willemb@google.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35002 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759807AbdAKCb0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 21:31:26 -0500
In-Reply-To: <1484079855.21472.36.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 Jan 2017 12:24:15 -0800

> From: Herbert Xu <herbert@gondor.apana.org.au>
> 
> The GRO fast path caches the frag0 address.  This address becomes
> invalid if frag0 is modified by pskb_may_pull or its variants.
> So whenever that happens we must disable the frag0 optimization.
> 
> This is usually done through the combination of gro_header_hard
> and gro_header_slow, however, the IPv6 extension header path did
> the pulling directly and would continue to use the GRO fast path
> incorrectly.
> 
> This patch fixes it by disabling the fast path when we enter the
> IPv6 extension header path.
> 
> Fixes: 78a478d0efd9 ("gro: Inline skb_gro_header and cache frag0 virtual address")
> Reported-by: Slava Shwartsman <slavash@mellanox.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
