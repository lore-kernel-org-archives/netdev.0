From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: remove invalid __rcu annotation
Date: Tue, 25 Jun 2013 02:44:38 -0700 (PDT)
Message-ID: <20130625.024438.272501145166501401.davem@davemloft.net>
References: <1372148466.3301.85.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hkchu@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53314 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896Ab3FYJom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 05:44:42 -0400
In-Reply-To: <1372148466.3301.85.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Jun 2013 01:21:06 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> struct tcp_fastopen_context has a field named tfm, which is a pointer
> to a crypto_cipher structure.
> 
> It currently has a __rcu annotation, which is not needed at all.
> 
> tcp_fastopen_ctx is the pointer fetched by rcu_dereference(), but once
> we have a pointer to current tcp_fastopen_context, we do not use/need
> rcu_dereference() to access tfm.
> 
> This fixes a lot of sparse errors like the following :
> 
> net/ipv4/tcp_fastopen.c:21:31: warning: incorrect type in argument 1 (different address spaces)
> net/ipv4/tcp_fastopen.c:21:31:    expected struct crypto_cipher *tfm
> net/ipv4/tcp_fastopen.c:21:31:    got struct crypto_cipher [noderef] <asn:4>*tfm
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
