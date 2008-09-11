From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Thu, 11 Sep 2008 20:45:31 +1000
Message-ID: <20080911104531.GA21913@gondor.apana.org.au>
References: <20080821064941.GA2764@ff.dom.local> <20080821071634.GA1269@gondor.apana.org.au> <20080821.005250.117238212.davem@davemloft.net> <20080911.033956.233317469.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48948 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752223AbYIKKpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 06:45:38 -0400
Content-Disposition: inline
In-Reply-To: <20080911.033956.233317469.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2008 at 03:39:56AM -0700, David Miller wrote:
>
> I got to looking into this and we do need the qdisc->dev_queue member,
> see qdisc_run().  So it's not like we can get rid of it if we replace
> it with ->netdevdev and add a ->root_qdisc backpointer as well.

That can't be right.  Let's I've got a single qdisc shared by
n queues.  It makes no sense for qdisc_run to decide to whether
it should process the qdisc depending on the status of a single
one out of the n queues.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
