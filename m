From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: [NET]: Prevent multiple qdisc runs
Date: Sat, 24 Jun 2006 09:50:39 -0400
Message-ID: <1151157039.6716.71.camel@jzny2>
References: <20060619134227.GA16662@gondor.apana.org.au>
	 <1150727009.5815.72.camel@jzny2>
	 <20060619142928.GA17191@gondor.apana.org.au>
	 <1150727810.5815.78.camel@jzny2>
	 <20060619223326.GA20354@gondor.apana.org.au>
	 <1150814526.5270.64.camel@jzny2>
	 <20060620235207.GA31493@gondor.apana.org.au>
	 <1151004682.5392.97.camel@jzny2>
	 <20060622224302.GA10136@gondor.apana.org.au>
	 <1151023937.5099.40.camel@jzny2>
	 <20060623033525.GA11751@gondor.apana.org.au>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.znyx.com ([208.2.156.141]:41745 "EHLO mailhub.znyx.com")
	by vger.kernel.org with ESMTP id S1750713AbWFXNvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jun 2006 09:51:21 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060623033525.GA11751@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-23-06 at 13:35 +1000, Herbert Xu wrote: 
> On Thu, Jun 22, 2006 at 08:52:17PM -0400, jamal wrote:
> > 
> > It does feel like the qdisc_is_running though is now a replacement
> > for the need for dev->txlock which existed to protect multi-cpus from
> > entering the device transmit path. Is that unintended side effect?
> > i.e why would dev->txlock be needed anymore in that path?
> 
> It's not totally redundant yet since you can set tx_queue_len to zero.
> It also still protects against the asynchronous paths that take xmit_lock.

The tx_timeout? 

> However, it wouldn't be a bad idea to see if there is a way to reduce the
> number of locks required on the xmit path to one.

It also seems to be there - dont know why it took me so long to see
this. I am actually gut-feeling now that we may get better performance
with LLTX drivers with this approach;-> talk about a flip-flop.

The qualification for LLTX seems to be for a driver to have a
private tx lock which is the case of about every ethernet driver out
there.

cheers,
jamal


