From: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 6 Aug 2006 09:14:18 +0200
Message-ID: <20060806071418.GB20432@edgar.underground.se.axis.com>
References: <20060804101017.GA17393@gondor.apana.org.au> <1154712532.3117.43.camel@rh4> <20060804110829.62136ebb@dxpl.pdx.osdl.net> <20060804.163111.85390037.davem@davemloft.net> <1154797002.5081.21.camel@jzny2> <20060805230517.GA25468@gondor.apana.org.au> <1154819868.5517.34.camel@jzny2> <20060805231959.GA25768@gondor.apana.org.au> <1154821010.5517.48.camel@jzny2> <20060806025123.GA27051@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, David Miller <davem@davemloft.net>,
	shemminger@osdl.org, mchan@broadcom.com,
	jesse.brandeburg@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:57494 "EHLO
	miranda.se.axis.com") by vger.kernel.org with ESMTP
	id S1750760AbWHFHOV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 03:14:21 -0400
Received: from axis.com (edgar.se.axis.com [10.92.151.1])
	by miranda.se.axis.com (8.12.9/8.12.9/Debian-5local0.1) with ESMTP id k767EIP0023750
	for <netdev@vger.kernel.org>; Sun, 6 Aug 2006 09:14:18 +0200
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060806025123.GA27051@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 06, 2006 at 12:51:23PM +1000, Herbert Xu wrote:
>
> I wonder if we could do the TX clean up within the transmission
> routine most of the time.  Has anyone tried this before?
> 

Hi Herbert,

Not sure what you mean with "most of the time" but a while a go I played 
around with a something like this for another driver. The tx path was cleaning 
up the tx ring at certain intervals while the tx irq-handler was not touching 
the ring unless it had become full. Actually the tx irq was disabled most of 
the time and ring manipulation became simpler. 

Later I ended up throwing this away as it was causing some TCP connections to
deadlock. If you let skb's sit in the tx-ring indefintely, the 
sk->sk_wmem_queued accounting will be inacurate and this was causing the TCP 
retransmit logic to deadlock. 

Again, I'm not sure what you mean with "most of the time" but if you make sure 
the tx-ring is continously beeing cleaned-up, even tough no more packets are 
beeing generated, maybe it could work. 

I hope this wasn't completely irrelevant..

Best regards,
-- 
        Programmer
        Edgar E. Iglesias <edgar.iglesias@axis.com> 46.46.272.1946
