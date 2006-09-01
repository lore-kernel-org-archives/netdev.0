From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][IPSEC]: tunnel mode processing
Date: Fri, 01 Sep 2006 08:56:18 -0400
Message-ID: <1157115379.5057.84.camel@jzny2>
References: <1157072127.5057.39.camel@jzny2>
	 <20060901040713.GA9840@gondor.apana.org.au>
	 <1157113034.5057.62.camel@jzny2>
	 <20060901122255.GA18143@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:59573 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1750731AbWIAM4Y
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 08:56:24 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GJ8ZM-0005h8-Dw
	for netdev@vger.kernel.org; Fri, 01 Sep 2006 08:56:24 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060901122255.GA18143@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-01-09 at 22:22 +1000, Herbert Xu wrote:

> Right, you're testing the receiver side.  

both in/out sides (on the receiver); i just count and drop all packets
coming back to the sender (the pktgenerator)

> In that case I suggest that
> you replicate the IPsec transport mode logic in the generator.  

Tunnel mode you mean, i think.

> Just
> as pktgen doesn't use net/ipv4/udp.c to generate UDP traffic, it doesn't
> really need to use xfrm4_output.c to generate IPsec traffic.
> 

IPsec is slightly different since i need to use state in the core. i.e
it is stateful. Nothing that pktgen does today has such requirements.

> You can still call down to esp4.c through the type pointer of course.

Thats one idea i havent thought of. 

i.e the code would look like:
-----
        if (mode == tunnel) 
		err = mytunneloutput (x, skb);
	else 
        	err = x->mode->output(x, skb);
        if (err)
                goto error;
        err = x->type->output(x, skb);
--

This is what you are suggesting?
I am probably better off going back to creating a dummy dst with just
those two fields when in  tunnel mode;->

cheers,
jamal

