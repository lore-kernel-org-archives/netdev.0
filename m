From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Fix dev->qdisc race for NETDEV_TX_LOCKED case
Date: Thu, 10 May 2007 04:56:18 -0700 (PDT)
Message-ID: <20070510.045618.36663267.davem@davemloft.net>
References: <20070510094228.GG521@postel.suug.ch>
	<E1Hm7Er-0006Wk-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45676
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758354AbXEJL4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 07:56:15 -0400
In-Reply-To: <E1Hm7Er-0006Wk-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 10 May 2007 21:55:17 +1000

> Thomas Graf <tgraf@suug.ch> wrote:
> > When transmit fails with NETDEV_TX_LOCKED the skb is requeued
> > to dev->qdisc again. The dev->qdisc pointer is protected by
> > the queue lock which needs to be dropped when attempting to
> > transmit and acquired again before requeing. The problem is
> > that qdisc_restart() fetches the dev->qdisc pointer once and
> > stores it in the `q' variable which is invalidated when
> > dropping the queue_lock, therefore the variable needs to be
> > refreshed before requeueing.
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> I agree, good catch Thomas.

Applied to my tree and I'll push it off to Linus tomorrow unless
someone finds a problem with it by then.

Thanks.
