From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH] net: codel: Avoid undefined behavior from
 signed overflow
Date: Wed, 30 Oct 2013 20:19:12 +0000
Message-ID: <1383164352.1601.38.camel@bwh-desktop.uk.level5networks.com>
References: <20131030172341.19203.93490.stgit@dragon>
	 <1383161748.1601.24.camel@bwh-desktop.uk.level5networks.com>
	 <20131030201327.GO4126@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	<netdev@vger.kernel.org>, "Eric Dumazet" <eric.dumazet@gmail.com>,
	Dave Taht <dave.taht@gmail.com>
To: <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:59761 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752564Ab3J3UTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 16:19:17 -0400
In-Reply-To: <20131030201327.GO4126@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-30 at 13:13 -0700, Paul E. McKenney wrote:
> On Wed, Oct 30, 2013 at 07:35:48PM +0000, Ben Hutchings wrote:
> > On Wed, 2013-10-30 at 18:23 +0100, Jesper Dangaard Brouer wrote:
> > > From: Jesper Dangaard Brouer <netoptimizer@brouer.com>
> > > 
> > > As described in commit 5a581b367 (jiffies: Avoid undefined
> > > behavior from signed overflow), according to the C standard
> > > 3.4.3p3, overflow of a signed integer results in undefined
> > > behavior.
> > [...]
> > 
> > According to the real processors that Linux runs on, signed arithmetic
> > uses 2's complement representation and overflow wraps accordingly.  And
> > we rely on that behaviour in many places, so we use
> > '-fno-strict-overflow' to tell gcc not to assume we avoid signed
> > overflow.  (There is also '-fwrapv' which tells gcc to assume the
> > processor behaves this way, but shouldn't it already know how the target
> > machine works?)
> 
> We should still fix them as we come across them.  There are a few types
> of loops where '-fno-strict-overflow' results in more instructions
> being generated.

I realise there's an opportunity for optimisation, but if these cases
are fixed on an ad-hoc basis, how will we know we're ready to make the
switch?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
