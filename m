From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 20:58:15 +1000
Message-ID: <20080819105815.GA30148@gondor.apana.org.au>
References: <20080818.164748.86676462.davem@davemloft.net> <20080819103151.GA6408@ff.dom.local> <20080819105133.GA30020@gondor.apana.org.au> <20080819.035406.107673885.davem@davemloft.net> <20080819105551.GA30114@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54265 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751526AbYHSK6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 06:58:22 -0400
Content-Disposition: inline
In-Reply-To: <20080819105551.GA30114@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 08:55:51PM +1000, Herbert Xu wrote:
> On Tue, Aug 19, 2008 at 03:54:06AM -0700, David Miller wrote:
> >
> > Every qdisc_run() will invoke __netif_schedule() so it is
> > a fast path I think :-)
> 
> Argh, I meant __netif_reschedule which shouldn't be the fast path.

Nevermind, both paths call __netif_reschedule :)

OK, how about just moving it to the else clause in net_tx_action?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
