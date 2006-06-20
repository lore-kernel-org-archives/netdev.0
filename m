From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Prevent multiple qdisc runs
Date: Wed, 21 Jun 2006 09:52:07 +1000
Message-ID: <20060620235207.GA31493@gondor.apana.org.au>
References: <20060619121519.GA16031@gondor.apana.org.au> <1150724031.5815.39.camel@jzny2> <20060619134227.GA16662@gondor.apana.org.au> <1150727009.5815.72.camel@jzny2> <20060619142928.GA17191@gondor.apana.org.au> <1150727810.5815.78.camel@jzny2> <20060619223326.GA20354@gondor.apana.org.au> <1150814526.5270.64.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:11788 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750990AbWFTXwV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 19:52:21 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1150814526.5270.64.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 20, 2006 at 10:42:06AM -0400, jamal wrote:
> 
> I apologize for hand-waving with % numbers above and using gut feeling
> instead of experimental facts - I dont have time to chase it. I have
> CCed Robert who may have time to see if this impacts forwarding
> performance for one. I will have more peace of mind to find out there is
> no impact.

Well my gut feeling is that multiple qdisc_run's on the same dev can't
be good for perfomance.  The reason is that SMP is only good when the
CPUs work on different tasks.  If you get two or more CPUs to work on
qdisc_run at the same time they can still only supply one skb to the
device at any time.  What's worse is that they will now have to fight
over the two spin locks involved which means that their cache lines
will bounce back and forth.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
