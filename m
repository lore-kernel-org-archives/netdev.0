From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Lockup with tun/tap/bridge interface deregistration.
Date: Thu, 11 Dec 2008 21:49:54 +1100
Message-ID: <20081211104954.GA25179@gondor.apana.org.au>
References: <87fxkwhyyq.fsf@barad-dur.regala.cx> <20081211102421.GB4129@ff.dom.local> <20081211104303.GC4129@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mathieu SEGAUD <mathieu.segaud@regala.cx>, netdev@vger.kernel.org,
	kernel@gentoo.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40228 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754772AbYLKKuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 05:50:02 -0500
Content-Disposition: inline
In-Reply-To: <20081211104303.GC4129@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 11, 2008 at 10:43:03AM +0000, Jarek Poplawski wrote:
> On Thu, Dec 11, 2008 at 10:24:21AM +0000, Jarek Poplawski wrote:
> ...
> > Could you try e.g. 2.6.27.7 or something with this patch?:
> > 
> > http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.27.y.git;a=commit;h=58ec3b4db9eb5a28e3aec5f407a54e28f7039c19
> 
> Oops! 2.6.27.4 has this too...

Right, this fixes a dead-lock that causes the RTNL to be held which
doesn't seem to be the case here.  It sounds like the problem in
this thread is simply due to a non-zero ref count on the netdev
itself.

Mathieu, you should get a message like this

	unregister_netdevice: waiting for %s to become free. Usage count = %d

What does your count say?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
