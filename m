From: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 6 Aug 2006 09:30:57 +0200
Message-ID: <20060806073057.GC20432@edgar.underground.se.axis.com>
References: <20060806071418.GB20432@edgar.underground.se.axis.com> <E1G9d05-0007SR-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Edgar E. Iglesias" <edgar.iglesias@axis.com>, hadi@cyberus.ca,
	davem@davemloft.net, shemminger@osdl.org, mchan@broadcom.com,
	jesse.brandeburg@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:20633 "EHLO
	miranda.se.axis.com") by vger.kernel.org with ESMTP id S932377AbWHFHa7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 03:30:59 -0400
Received: from axis.com (edgar.se.axis.com [10.92.151.1])
	by miranda.se.axis.com (8.12.9/8.12.9/Debian-5local0.1) with ESMTP id k767UvP0024887
	for <netdev@vger.kernel.org>; Sun, 6 Aug 2006 09:30:57 +0200
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1G9d05-0007SR-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 06, 2006 at 05:24:41PM +1000, Herbert Xu wrote:
> Edgar E. Iglesias <edgar.iglesias@axis.com> wrote:
> > 
> > Not sure what you mean with "most of the time" but a while a go I played 
> > around with a something like this for another driver. The tx path was cleaning 
> > up the tx ring at certain intervals while the tx irq-handler was not touching 
> > the ring unless it had become full. Actually the tx irq was disabled most of 
> > the time and ring manipulation became simpler. 
> 
> Yes that's exactly what I mean :)
> 
> > Later I ended up throwing this away as it was causing some TCP connections to
> > deadlock. If you let skb's sit in the tx-ring indefintely, the 
> > sk->sk_wmem_queued accounting will be inacurate and this was causing the TCP 
> > retransmit logic to deadlock. 
> 
> Yes you need to clean the ring if the TX queue becomes empty or you'll
> risk dead locks.
> 
> What driver was this and did you do any performance measurements?
> 

It was for the cris/eth_v10.c driver. Performance bumped with 20% for UDP if I remember correctly, TCP was much less. I'll try to dig up the numbers.

On UP non-preemptive kenrnels the tx-path used no interrupts and had no locks to manipulate the ring. But I am guessing that part of the performance win also came by freeing the skb's in chunks.

Best regards
-- 
        Programmer
        Edgar E. Iglesias <edgar.iglesias@axis.com> 46.46.272.1946
