From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 07 Aug 2006 15:34:30 -0400
Message-ID: <1154979270.5446.97.camel@jzny2>
References: <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com>
	 <1154955036.5246.32.camel@jzny2>
	 <20060807152126.GL24653@edgar.underground.se.axis.com>
	 <1154965249.5446.15.camel@jzny2>
	 <20060807155929.GM24653@edgar.underground.se.axis.com>
	 <1154968319.5446.30.camel@jzny2>
	 <20060807170403.GA10818@edgar.underground.se.axis.com>
	 <1154973625.5446.56.camel@jzny2>
	 <20060807184748.GA10909@edgar.underground.se.axis.com>
	 <1154977413.5446.83.camel@jzny2>
	 <20060807191413.GB10909@edgar.underground.se.axis.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:14224 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932238AbWHGTed
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 15:34:33 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GAAs1-0004yA-SF
	for netdev@vger.kernel.org; Mon, 07 Aug 2006 15:34:37 -0400
To: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
In-Reply-To: <20060807191413.GB10909@edgar.underground.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-07-08 at 21:14 +0200, Edgar E. Iglesias wrote:

> > If yes, what is the likelihood they will sit there forever? I think
> > perhaps some TX interupts will happen, no?
> 
> with jamal undefined, absolutely. With jamal defined, TX interrupts will come
> but I couldnt find a way into e1000_prune_tx_ring unless fdesc met the 
> conditions. Correct? 
> 

Forgive me since i am still missing something ..

Observe that the same threshold used in two different ways:

1) in tx path tx_ring->prunet is to check on when we should _start_ to
prune.
2) on rx path tx_ring->prunet is to check when to _stop_ pruning.

i.e #1 is a preemptive action.

You seem to suggest doing it the way i was it made things worse?

Note that TX interrupts will happen as long as you dont prune some
descriptors (I am assuming this, I havent checked the settings).

cheers,
jamal


