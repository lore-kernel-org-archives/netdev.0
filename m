From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [net-next PATCH] net: codel: Avoid undefined behavior from
 signed overflow
Date: Wed, 30 Oct 2013 13:13:27 -0700
Message-ID: <20131030201327.GO4126@linux.vnet.ibm.com>
References: <20131030172341.19203.93490.stgit@dragon>
 <1383161748.1601.24.camel@bwh-desktop.uk.level5networks.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Taht <dave.taht@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:54691 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753627Ab3J3UNe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 16:13:34 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 30 Oct 2013 16:13:33 -0400
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 09ED2C9003E
	for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 16:13:29 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9UKDTKF5505326
	for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 20:13:29 GMT
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r9UKGJkR004983
	for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 14:16:19 -0600
Content-Disposition: inline
In-Reply-To: <1383161748.1601.24.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 30, 2013 at 07:35:48PM +0000, Ben Hutchings wrote:
> On Wed, 2013-10-30 at 18:23 +0100, Jesper Dangaard Brouer wrote:
> > From: Jesper Dangaard Brouer <netoptimizer@brouer.com>
> > 
> > As described in commit 5a581b367 (jiffies: Avoid undefined
> > behavior from signed overflow), according to the C standard
> > 3.4.3p3, overflow of a signed integer results in undefined
> > behavior.
> [...]
> 
> According to the real processors that Linux runs on, signed arithmetic
> uses 2's complement representation and overflow wraps accordingly.  And
> we rely on that behaviour in many places, so we use
> '-fno-strict-overflow' to tell gcc not to assume we avoid signed
> overflow.  (There is also '-fwrapv' which tells gcc to assume the
> processor behaves this way, but shouldn't it already know how the target
> machine works?)

We should still fix them as we come across them.  There are a few types
of loops where '-fno-strict-overflow' results in more instructions
being generated.

							Thanx, Paul
