From: David Miller <davem@davemloft.net>
Subject: Re: net: Fix skb_set_peeked use-after-free bug
Date: Thu, 06 Aug 2015 21:56:28 -0700 (PDT)
Message-ID: <20150806.215628.1038906181820631420.davem@davemloft.net>
References: <CAMUH3-WyNR+2tsKgZ2qMNR=p+2Q3WDjcPrQcVSZfVSVyPA1qoA@mail.gmail.com>
	<20150804074247.GA29951@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bblanco@plumgrid.com, netdev@vger.kernel.org,
	khlebnikov@yandex-team.ru
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45532 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753809AbbHGE43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 00:56:29 -0400
In-Reply-To: <20150804074247.GA29951@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 4 Aug 2015 15:42:47 +0800

> The commit 738ac1ebb96d02e0d23bc320302a6ea94c612dec ("net: Clone
> skb before setting peeked flag") introduced a use-after-free bug
> in skb_recv_datagram.  This is because skb_set_peeked may create
> a new skb and free the existing one.  As it stands the caller will
> continue to use the old freed skb.
> 
> This patch fixes it by making skb_set_peeked return the new skb
> (or the old one if unchanged).
> 
> Fixes: 738ac1ebb96d ("net: Clone skb before setting peeked flag")
> Reported-by: Brenden Blanco <bblanco@plumgrid.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, and since the commit this is fixing is queued up for -stable
I'll of course queue this up too.
