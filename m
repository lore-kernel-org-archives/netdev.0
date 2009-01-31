From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sat, 31 Jan 2009 11:35:02 +0300
Message-ID: <20090131083502.GA26897@ioremap.net>
References: <20090130112125.GA9908@ioremap.net> <20090130125337.GA7155@gondor.apana.org.au> <20090130095737.103edbff@extreme> <498349F7.4050300@cosmosbay.com> <20090130215008.GB12210@ioremap.net> <49837F7E.90306@cosmosbay.com> <20090130225113.GA13977@ioremap.net> <20090130163600.0be8c137@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, berrange@redhat.com,
	et-mgmt-tools@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrixpower.ru ([195.178.208.66]:54820 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953AbZAaIfX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2009 03:35:23 -0500
Content-Disposition: inline
In-Reply-To: <20090130163600.0be8c137@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 04:36:00PM -0800, Stephen Hemminger (shemminger@vyatta.com) wrote:
> > It is not a bug. It is not supposed to be precise. At all.
> > I implemented a simple heuristic on when diferent bind port selection
> > algorithm should start: roughly when number of opened sockets equals to
> > some predefined value (sysctl at the moment, but it could be 64k or
> > anything else), so if that number is loosely maintained and does not
> > precisely corresponds to the number of sockets, it is not a problem.
> > 
> > You also saw 'again' lavel which has magic 5 number - it is another
> > heuristic - since lock is dropped atfer the bind bucket check, and we
> > selected it, it is possible that non-reuse socket will be added into the
> > bucket, so we will have to rerun the process again. I limited this to
> > the 5 attempts only, since it is better than what we have right now (I
> > never saw more than 2 attempts needed in the tests), when number of
> > bound sockets does not exceed 64k.
> > 
> >
> 
> How is any of this supposed to fix the bug?

Nothing from above fixes the bug. It was an explaination of how things
work. Patch is based on Eric's observation about unconditional (compared
to old code) attempt to get the new socket bucket when code should just
return.

-- 
	Evgeniy Polyakov
