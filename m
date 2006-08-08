From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 07 Aug 2006 23:10:14 -0400
Message-ID: <1155006614.5138.50.camel@jzny2>
References: <1154797002.5081.21.camel@jzny2>
	 <20060805230517.GA25468@gondor.apana.org.au>
	 <1154819868.5517.34.camel@jzny2>
	 <20060805231959.GA25768@gondor.apana.org.au>
	 <1154821010.5517.48.camel@jzny2>
	 <20060806025123.GA27051@gondor.apana.org.au>
	 <1154867083.6269.35.camel@jzny2> <1154999971.5138.19.camel@jzny2>
	 <20060808012217.GA12468@gondor.apana.org.au>
	 <1155000832.5138.31.camel@jzny2>
	 <20060808021711.GA12795@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com,
	"Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:34257 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751224AbWHHDKS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 23:10:18 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GAHz7-00082E-4t
	for netdev@vger.kernel.org; Mon, 07 Aug 2006 23:10:25 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060808021711.GA12795@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-08 at 12:17 +1000, Herbert Xu wrote:

> CPU0				CPU1
> __qdisc_run
> 	netif_queue_stopped
> 				netif_wake_queue
> 					__netif_schedule
> 						test_bit
> 	clear_bit
> 
> So you may end up losing that wake event.  

Indeed you may.
I think what i was seeing is (motivating the patch to begin with) is:
if you got out of qdisc restart because driver returned TX_BUSY
leading to a netif_queue_stopped then you will have rescheduled on CPU0.
The only exception is the one example i mentioned in earlier email where
a TX_OK is returned by e1000. 

> The QDISC_RUNNING bit was
> originally designed to be used under the qdisc lock, so using it
> in a different contexts will require new synchronisation mechanisms.

Agreed.

cheers,
jamal


