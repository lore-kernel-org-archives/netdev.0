From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 06 Aug 2006 17:24:41 +1000
Message-ID: <E1G9d05-0007SR-00@gondolin.me.apana.org.au>
References: <20060806071418.GB20432@edgar.underground.se.axis.com>
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca, davem@davemloft.net,
	shemminger@osdl.org, mchan@broadcom.com,
	jesse.brandeburg@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:12818 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932483AbWHFHZX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 03:25:23 -0400
To: edgar.iglesias@axis.com (Edgar E. Iglesias)
In-Reply-To: <20060806071418.GB20432@edgar.underground.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Edgar E. Iglesias <edgar.iglesias@axis.com> wrote:
> 
> Not sure what you mean with "most of the time" but a while a go I played 
> around with a something like this for another driver. The tx path was cleaning 
> up the tx ring at certain intervals while the tx irq-handler was not touching 
> the ring unless it had become full. Actually the tx irq was disabled most of 
> the time and ring manipulation became simpler. 

Yes that's exactly what I mean :)

> Later I ended up throwing this away as it was causing some TCP connections to
> deadlock. If you let skb's sit in the tx-ring indefintely, the 
> sk->sk_wmem_queued accounting will be inacurate and this was causing the TCP 
> retransmit logic to deadlock. 

Yes you need to clean the ring if the TX queue becomes empty or you'll
risk dead locks.

What driver was this and did you do any performance measurements?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
