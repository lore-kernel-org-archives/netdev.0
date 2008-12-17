From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 15:23:33 -0800 (PST)
Message-ID: <20081217.152333.89527205.davem@davemloft.net>
References: <20081217104254.GA17407@gondor.apana.org.au>
	<1229511143.13305.23.camel@nathan.suse.cz>
	<20081217112600.GA19106@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ptesarik@suse.cz, ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57934
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751049AbYLQXXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 18:23:31 -0500
In-Reply-To: <20081217112600.GA19106@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 17 Dec 2008 22:26:00 +1100

> 	if (SEQ_GT(tp->snd_up, tp->snd_nxt)) {
> 		u_int32_t urp = tp->snd_up - tp->snd_nxt;
> 		if (urp > IP_MAXPACKET)
> 			urp = IP_MAXPACKET;
> 		th->th_urp = htons((u_int16_t)urp);
> 		th->th_flags |= TH_URG;
> 	} else  
> 
> So if you think this is bad then it's been there for decades :)

No, this is a hack the BSD guys added.

This code does not appear in Richard Steven's TCP/IP Illustrated
Volume 2, as I showed in my other reply.

And bad or not, you cannot compare exposure and deployment of
the BSD stack compared to say our's or Microsoft's.  Especially
in such the unusual circumstance of URG with the URG pointer
outside of the 16-bit offset limit.

Your quick discovery of the retransmit bug nearly proves this :)

