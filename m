From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Fri, 5 Jan 2007 07:38:44 +0100
Message-ID: <20070105063844.GA1675@ff.dom.local>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com> <E1H2M3X-0001HE-00@gondolin.me.apana.org.au> <20070104.123333.91315611.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, dlstevens@us.ibm.com,
	greearb@candelatech.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:36623 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030352AbXAEGhD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jan 2007 01:37:03 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20070104.123333.91315611.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 04, 2007 at 12:33:33PM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 04 Jan 2007 17:26:27 +1100
> 
> > David Stevens <dlstevens@us.ibm.com> wrote:
> > >        You're right, I don't know whether it'll fix the problem Ben saw
> > > or not, but it looks like the original code can do a receive before the
> > > in_device is fully initialized, and that, of course, is bad.
> > >        If the device for ip_rcv() is not the same one we were
> > > initializing when the receive interrupted, then the patch should have
> > > no effect either way -- I don't think it'll hide other problems.
> > >        If it's hard to reproduce (which I guess is true), then you're
> > > right, no soft lockup doesn't really tell us if it's fixed or not.
> > 
> > Actually I missed your point that the multicast locks aren't even
> > initialised at that point.  So this does explain the soft lock-up
> > and therefore your patch is clearly the correct solution.
> 
> I agree too, therefore I've added David's patch as below.
> 
> I'll push this to the -stable branches as well.  This fix is
> correct even if it does not entirely clear up the soft lockup
> bug being discussed in this thread, but I think it will :-)

After rethinking I came to similar conclusion.  I've
thought the changes are done only to fix this particular
bug but now I see the previous order wasn't right
particularly considering RCU.

So, I apologize to David L Stevens for my harsh words.

I'd only suggest to change "goto out;" to
"return NULL;" at the end of inetdev_init because
now RCU is engaged unnecessarily.

Regards,
Jarek P.
