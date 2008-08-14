From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 14 Aug 2008 18:16:32 +1000
Message-ID: <20080814081632.GB32475@gondor.apana.org.au>
References: <20080813102701.GD5367@ff.dom.local> <20080813104238.GA11374@gondor.apana.org.au> <20080813105052.GA6838@ff.dom.local> <20080813.151918.61294677.davem@davemloft.net> <20080814075907.GA6797@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37261 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752129AbYHNIQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 04:16:37 -0400
Content-Disposition: inline
In-Reply-To: <20080814075907.GA6797@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2008 at 07:59:07AM +0000, Jarek Poplawski wrote:
> 
> net: Change handling of the __QDISC_STATE_SCHED flag in net_tx_action().
> 
> Change handling of the __QDISC_STATE_SCHED flag in net_tx_action() to
> enable proper control in dev_deactivate_queue(). Now, if this flag is
> seen as unset under root_lock means a qdisc can't be netif_scheduled.
> 
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Well this probably works in practice but at least on paper it
is vulnerable to live-lock if the net_tx_action side always gets
to the trylock stage and loses to the waiting side.

An aliveness flag would be the safest.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
