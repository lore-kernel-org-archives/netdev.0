From: David Miller <davem@davemloft.net>
Subject: Re: net: Fix skb csum races when peeking
Date: Wed, 15 Jul 2015 16:14:13 -0700 (PDT)
Message-ID: <20150715.161413.2184222881594096375.davem@davemloft.net>
References: <CANn89iLFCJWqmfvwOUB_7VUk_7jHHvOHZR6=fufDr848thSrHQ@mail.gmail.com>
	<20150713083100.GA9263@gondor.apana.org.au>
	<20150713120142.GA9787@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, eric.dumazet@gmail.com,
	khlebnikov@yandex-team.ru, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33521 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753399AbbGOXOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 19:14:14 -0400
In-Reply-To: <20150713120142.GA9787@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 13 Jul 2015 20:01:42 +0800

> When we calculate the checksum on the recv path, we store the
> result in the skb as an optimisation in case we need the checksum
> again down the line.
> 
> This is in fact bogus for the MSG_PEEK case as this is done without
> any locking.  So multiple threads can peek and then store the result
> to the same skb, potentially resulting in bogus skb states.
> 
> This patch fixes this by only storing the result if the skb is not
> shared.  This preserves the optimisations for the few cases where
> it can be done safely due to locking or other reasons, e.g., SIOCINQ.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied and queued up for -stable, thanks!
