From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][IPSEC]: tunnel mode processing
Date: Fri, 01 Sep 2006 08:17:14 -0400
Message-ID: <1157113034.5057.62.camel@jzny2>
References: <1157072127.5057.39.camel@jzny2>
	 <20060901040713.GA9840@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:12457 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750845AbWIAMRV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 08:17:21 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GJ7xZ-0005ym-EQ
	for netdev@vger.kernel.org; Fri, 01 Sep 2006 08:17:21 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060901040713.GA9840@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-01-09 at 14:07 +1000, Herbert Xu wrote:
> On Thu, Aug 31, 2006 at 08:55:27PM -0400, jamal wrote:
> > 
> > Would it be reasonable to do a check so that incase a skb->dst doesnt
> > exist, the inner headers values can be used i.e something along 
> > xfrm4_tunnel_output()::
> 
> If you didn't care what values they were, couldn't you just stuff some
> bogus dst into the skb? 

That bogus dst is NULL ;->

> If this packet is going somewhere you're going
> to have a dst one way or another :)

If i was going to use routing/layer 3, then true. At the pktgen level
"somewhere" is just "shove down the ether". Actually (i havent thought
clearly about this) wouldnt a bump in the wire implementation aka
bridging level also not care about route details? 
Note: This does not absolve the need for a secure ipid or a proper ttl.

> Also, the IPID is only generated if DF is not set on the packet.
> Otherwise this path is already as fast as it can be.

In the case of traffic generation, if i could shave even more cycles the
better since i want to generate high speed. In this case the cycles
would be in creating a fake dst and attaching it some fake values.

I do agree that it is an awkward way of achieving my goals - but i dont
know of a clever way to do it ;->

cheers,
jamal

