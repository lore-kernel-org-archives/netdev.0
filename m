From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] pktgen IPSEC 3/4: Introduce xfrm SAD only lookup
Date: Tue, 12 Jun 2007 11:19:23 -0400
Message-ID: <1181661564.4067.40.camel@localhost>
References: <1181649373.4060.50.camel@localhost>
	 <1181649628.4060.54.camel@localhost>  <1181649715.4060.56.camel@localhost>
	 <1181649791.4060.59.camel@localhost>  <466EA36E.80206@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, James Morris <jmorris@namei.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.236]:47404 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757179AbXFLPT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 11:19:28 -0400
Received: by wr-out-0506.google.com with SMTP id 76so1328262wra
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2007 08:19:27 -0700 (PDT)
In-Reply-To: <466EA36E.80206@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-12-06 at 15:45 +0200, Patrick McHardy wrote:
> Looks good too me, just a few minor nitpicks as usual :)

I like the nitpicks - they make the code better (as long as we put
a time limit on them ;->)

> 
> ^^ please delete empty line

will do.

> > +			if (x->km.state != XFRM_STATE_VALID)
> > +					continue;
> 
> ^ one indentation level too much

will fix.

> The whole thing could be compacted by moving the XFRM_STATE_VALID
> check to the first condition:
> 
> 		if (x->props.family == family &&
> 		    x->props.reqid == reqid &&
> 		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
> 		    xfrm_state_addr_check(x, daddr, saddr, family) &&
> 		    mode == x->props.mode &&
> 		    proto == x->id.proto &&
> 		    x->km.state == XFRM_STATE_VALID) {
> 			rx = x;
> 			break;
> 		}
> 
> or alternatively turn the != XFRM_STATE_VALID into == if you
> want to keep the first condition similar to xfrm_state_find
> (but the mode and proto conditions are reversed anyways).
> 

Will do.

> BTW, wouldn't it make sense to allow use of the SPI as well?

SPI is the least user friendly parameter - but i could add it later.
I want to add tunnel mode next then i can revisit SPI.

Thanks for taking the time to review this Patrick.

cheers,
jamal


