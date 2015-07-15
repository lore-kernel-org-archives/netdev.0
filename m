From: David Miller <davem@davemloft.net>
Subject: Re: net: Clone skb before setting peeked flag
Date: Wed, 15 Jul 2015 16:13:43 -0700 (PDT)
Message-ID: <20150715.161343.936469507696734723.davem@davemloft.net>
References: <20150710115141.12980.88829.stgit@buzz>
	<20150713072352.GA8485@gondor.apana.org.au>
	<20150713080413.GA8901@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khlebnikov@yandex-team.ru, netdev@vger.kernel.org,
	edumazet@google.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753768AbbGOXNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 19:13:44 -0400
In-Reply-To: <20150713080413.GA8901@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 13 Jul 2015 16:04:13 +0800

> Shared skbs must not be modified and this is crucial for broadcast
> and/or multicast paths where we use it as an optimisation to avoid
> unnecessary cloning.
> 
> The function skb_recv_datagram breaks this rule by setting peeked
> without cloning the skb first.  This causes funky races which leads
> to double-free.
> 
> This patch fixes this by cloning the skb and replacing the skb
> in the list when setting skb->peeked.
> 
> Fixes: a59322be07c9 ("[UDP]: Only increment counter on first peek/recv")
> Reported-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable.
