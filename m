From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH/RFC] net: Add __napi_sycnhronize() to sync with napi
	poll
Date: Tue, 16 Oct 2007 17:37:03 +1000
Message-ID: <1192520223.7205.5.camel@pasglop>
References: <E1IhfZr-0002FE-00@gondolin.me.apana.org.au>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	davem@davemloft.net, rdreier@cisco.com, linuxppc-dev@ozlabs.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54079 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755389AbXJPHhm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 03:37:42 -0400
In-Reply-To: <E1IhfZr-0002FE-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2007-10-16 at 14:06 +0800, Herbert Xu wrote:
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> >
> > Note: I use msleep_interruptible(1); just like napi_disable(). However
> > I'm not too happy that the "hot" loop that results of a pending signal
> > here will spin without even a cpu_relax ... what do you guys think would
> > be the best way to handle this ?
> 
> Well since the loop does not check signals at all, it should
> just use msleep.
> 
> Granted the process will end up in the D state and contribute
> to the load average.  But if this loop executes long enough
> for that to be noticed then we've got bigger problems to worry
> about.

If Dave & Stephen agree, I'll send a patch changing napi_disable() too
then.

Cheers,
Ben.


