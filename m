From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [net-next PATCH] net: codel: Avoid undefined behavior from
 signed overflow
Date: Wed, 30 Oct 2013 21:55:36 -0700
Message-ID: <20131031045536.GS4126@linux.vnet.ibm.com>
References: <20131030172341.19203.93490.stgit@dragon>
 <1383161748.1601.24.camel@bwh-desktop.uk.level5networks.com>
 <20131030201327.GO4126@linux.vnet.ibm.com>
 <1383164352.1601.38.camel@bwh-desktop.uk.level5networks.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Taht <dave.taht@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:50191 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762Ab3JaEzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 00:55:41 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 30 Oct 2013 22:55:40 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 65D083E40026
	for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 22:55:38 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9V4tccA225342
	for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 22:55:38 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r9V4wRhd010193
	for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 22:58:28 -0600
Content-Disposition: inline
In-Reply-To: <1383164352.1601.38.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 30, 2013 at 08:19:12PM +0000, Ben Hutchings wrote:
> On Wed, 2013-10-30 at 13:13 -0700, Paul E. McKenney wrote:
> > On Wed, Oct 30, 2013 at 07:35:48PM +0000, Ben Hutchings wrote:
> > > On Wed, 2013-10-30 at 18:23 +0100, Jesper Dangaard Brouer wrote:
> > > > From: Jesper Dangaard Brouer <netoptimizer@brouer.com>
> > > > 
> > > > As described in commit 5a581b367 (jiffies: Avoid undefined
> > > > behavior from signed overflow), according to the C standard
> > > > 3.4.3p3, overflow of a signed integer results in undefined
> > > > behavior.
> > > [...]
> > > 
> > > According to the real processors that Linux runs on, signed arithmetic
> > > uses 2's complement representation and overflow wraps accordingly.  And
> > > we rely on that behaviour in many places, so we use
> > > '-fno-strict-overflow' to tell gcc not to assume we avoid signed
> > > overflow.  (There is also '-fwrapv' which tells gcc to assume the
> > > processor behaves this way, but shouldn't it already know how the target
> > > machine works?)
> > 
> > We should still fix them as we come across them.  There are a few types
> > of loops where '-fno-strict-overflow' results in more instructions
> > being generated.
> 
> I realise there's an opportunity for optimisation, but if these cases
> are fixed on an ad-hoc basis, how will we know we're ready to make the
> switch?

I believe that there are some tools that check for code that relies on
signed integer overflow.  Probably not yet up to dealing with the
kernel.  In the meantime, fixing them as we come across them is not
a bad approach.

							Thanx, Paul
