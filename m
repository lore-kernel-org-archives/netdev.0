From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/8] net: Add Generic Receive Offload infrastructure
Date: Tue, 16 Dec 2008 08:37:58 -0800
Message-ID: <20081216163758.GA6681@linux.vnet.ibm.com>
References: <20081213013420.GA13549@gondor.apana.org.au> <E1LBJPd-0003YU-Ap@gondolin.me.apana.org.au> <20081215232942.GD6759@linux.vnet.ibm.com> <20081215.153920.105386030.davem@davemloft.net> <20081216020432.GA6454@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	johnpol@2ka.mipt.ru, bhutchings@solarflare.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:44859 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752728AbYLPQiC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 11:38:02 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mBGGbBPv018808
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 11:37:11 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBGGc0HP187288
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 11:38:00 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mBGHc9Wt020896
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 12:38:10 -0500
Content-Disposition: inline
In-Reply-To: <20081216020432.GA6454@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 16, 2008 at 01:04:32PM +1100, Herbert Xu wrote:
> On Mon, Dec 15, 2008 at 03:39:20PM -0800, David Miller wrote:
> > From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> >
> > > Presumably ptype_base[] is a static array rather than a dynamically
> > > allocated array that is resized under RCU protection, right?  Otherwise,
> > > you could get in trouble if the above raced with the resize operation due
> > > to the fact that you are outside of the RCU read-side critical section.
> > 
> > Yes, and we've been using RCU this way for this table for quite
> > some time.  From net/core/dev.c:
> > 
> > #define PTYPE_HASH_SIZE	(16)
> > #define PTYPE_HASH_MASK	(PTYPE_HASH_SIZE - 1)
> > 
> > static DEFINE_SPINLOCK(ptype_lock);
> > static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
> > static struct list_head ptype_all __read_mostly;	/* Taps */
> 
> Thanks for confirming.  Yes unless there is a sudden surge of
> new Ethernet protocols we shouldn't need to resize this ever :)

;-)

						Thanx, Paul
