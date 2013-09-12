From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv3 linux-next] hrtimer: Add notifier when clock_was_set
 was called
Date: Thu, 12 Sep 2013 23:44:10 +1000
Message-ID: <20130912134409.GB21212@gondor.apana.org.au>
References: <1375866296-15079-1-git-send-email-fan.du@windriver.com>
 <1375866296-15079-2-git-send-email-fan.du@windriver.com>
 <52021177.6020306@redhat.com>
 <520213F2.5090401@windriver.com>
 <520214C6.6000307@redhat.com>
 <520B4552.2000607@windriver.com>
 <alpine.DEB.2.02.1308181102230.4089@ionos.tec.linutronix.de>
 <5212CCCA.4090907@windriver.com>
 <alpine.DEB.2.02.1309121441420.4089@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fan Du <fan.du@windriver.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1309121441420.4089@ionos.tec.linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 12, 2013 at 03:21:24PM +0200, Thomas Gleixner wrote:
>
> > (3): http://www.spinics.net/lists/netdev/msg245169.html
> 
> Thanks for the explanation so far.
> 
> What's still unclear to me is why these timeouts are bound to wall
> time in the first place.
> 
> Is there any real reason why the key life time can't simply be
> expressed in monotonic time, e.g. N seconds after creation or M
> seconds after usage? Looking at the relevant RFCs I can't find any
> requirement for binding the life time to wall time. 
> 
> A life time of 10 minutes does not change when the wall clock is
> adjusted for whatever reasons. It's still 10 minutes and not some
> random result of the wall clock adjustments. But I might be wrong as
> usual :)

Well we started out with straight timers.  It was changed because
people wanted IPsec SAs to expire after a suspect/resume which
AFAIK does not touch normal timers.

Of course, this brought with it a new set of problems when the
system time is stepped which now cause SAs to expire even though
they probably shouldn't.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
