From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Fix dev->qdisc race for NETDEV_TX_LOCKED case
Date: Thu, 10 May 2007 21:55:17 +1000
Message-ID: <E1Hm7Er-0006Wk-00@gondolin.me.apana.org.au>
References: <20070510094228.GG521@postel.suug.ch>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: tgraf@suug.ch (Thomas Graf)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2764 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757987AbXEJLzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 07:55:37 -0400
In-Reply-To: <20070510094228.GG521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> wrote:
> When transmit fails with NETDEV_TX_LOCKED the skb is requeued
> to dev->qdisc again. The dev->qdisc pointer is protected by
> the queue lock which needs to be dropped when attempting to
> transmit and acquired again before requeing. The problem is
> that qdisc_restart() fetches the dev->qdisc pointer once and
> stores it in the `q' variable which is invalidated when
> dropping the queue_lock, therefore the variable needs to be
> refreshed before requeueing.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

I agree, good catch Thomas.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
