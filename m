From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] neigh: Add missing rcu_assign_pointer
Date: Thu, 28 May 2015 07:38:21 -0700
Message-ID: <1432823901.7456.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150528135044.GA8313@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:36052 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285AbbE1OiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 10:38:25 -0400
Received: by igbpi8 with SMTP id pi8so113436378igb.1
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 07:38:25 -0700 (PDT)
In-Reply-To: <20150528135044.GA8313@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-28 at 21:50 +0800, Herbert Xu wrote:

> This patch is indeed bogus but accessing an RCU-protected like
> this will trigger sparse warnings.  So better make it an
> RCU_INIT_POINTER.


A = B;  is perfectly fine since both A and B have the same __rcu
attribute.

Sparse has no warning and should not.

root@edumazet-glaptop2:/usr/src/net# grep CONFIG_SPARSE_RCU_POINTER .config
CONFIG_SPARSE_RCU_POINTER=y
root@edumazet-glaptop2:/usr/src/net# make C=2 CF=-D__CHECK_ENDIAN__ net/core/neighbour.o
...
  CHECK   net/core/neighbour.c
